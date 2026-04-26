import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { load } from "js-yaml";

const rootDir = join(dirname(fileURLToPath(import.meta.url)), "..");

type Schema = {
  type?: string | string[];
  properties?: Record<string, Schema>;
  required?: string[];
  items?: Schema;
  $ref?: string;
};

type Spec = {
  components?: { schemas?: Record<string, Schema> };
};

const refName = (ref: string) => ref.split("/").pop()!;

const toSnakeCase = (s: string) =>
  s.replace(/([A-Z])/g, "_$1").toLowerCase().replace(/^_/, "");

// 3.1: type が ["string", "null"] のような配列の場合に null を除いた実型を返す
function scalarType(schema: Schema): string {
  const types = Array.isArray(schema.type) ? schema.type : [schema.type ?? ""];
  return types.find((t) => t !== "null") ?? "";
}

function isNullable(schema: Schema): boolean {
  return Array.isArray(schema.type) && schema.type.includes("null");
}

function gleamType(schema: Schema, isRequired: boolean): string {
  let base: string;
  if (schema.$ref) {
    base = refName(schema.$ref);
  } else if (scalarType(schema) === "array") {
    base = `List(${gleamType(schema.items!, true)})`;
  } else {
    const map: Record<string, string> = {
      string: "String",
      integer: "Int",
      number: "Float",
      boolean: "Bool",
    };
    base = map[scalarType(schema)] ?? "Nil";
  }
  return isRequired && !isNullable(schema) ? base : `Option(${base})`;
}

function encodeExpr(schema: Schema, accessor: string, isRequired: boolean): string {
  const inner = (s: Schema, acc: string): string => {
    if (s.$ref) return `encode_${toSnakeCase(refName(s.$ref))}(${acc})`;
    if (scalarType(s) === "array") {
      const itemEnc = inner(s.items!, "item");
      return `json.array(${acc}, fn(item) { ${itemEnc} })`;
    }
    const map: Record<string, string> = {
      string: `json.string(${acc})`,
      integer: `json.int(${acc})`,
      number: `json.float(${acc})`,
      boolean: `json.bool(${acc})`,
    };
    return map[scalarType(s)] ?? "json.null()";
  };

  if (!isRequired || isNullable(schema)) {
    // シンプルな型はショートハンド形式を使う
    const shorthand: Record<string, string> = {
      string: "json.string",
      integer: "json.int",
      number: "json.float",
      boolean: "json.bool",
    };
    const sh = shorthand[scalarType(schema)];
    if (sh) return `json.nullable(${accessor}, ${sh})`;
    return `json.nullable(${accessor}, fn(inner) { ${inner(schema, "inner")} })`;
  }

  return inner(schema, accessor);
}

function generateBlock(name: string, schema: Schema): string {
  const required = new Set(schema.required ?? []);
  const props = Object.entries(schema.properties ?? {});

  const fields = props
    .map(([k, s]) => `    ${toSnakeCase(k)}: ${gleamType(s, required.has(k))}`)
    .join(",\n");

  const typeDef = `pub type ${name} {\n  ${name}(\n${fields},\n  )\n}`;

  const encoderFields = props
    .map(([k, s]) => {
      const enc = encodeExpr(s, `value.${toSnakeCase(k)}`, required.has(k));
      return `    #("${k}", ${enc})`;
    })
    .join(",\n");

  const encoderFn =
    `pub fn encode_${toSnakeCase(name)}(value: ${name}) -> json.Json {\n` +
    `  json.object([\n${encoderFields},\n  ])\n}`;

  return `${typeDef}\n\n${encoderFn}`;
}

function hasOptionalFields(schemas: Record<string, Schema>): boolean {
  return Object.values(schemas).some((schema) => {
    const required = new Set(schema.required ?? []);
    return Object.entries(schema.properties ?? {}).some(
      ([k, s]) => !required.has(k) || isNullable(s)
    );
  });
}

// main
const specPath = join(rootDir, "openapi", "openapi.yaml");
const outPath = join(rootDir, "backend", "src", "generated", "responses.gleam");

const spec = load(readFileSync(specPath, "utf8")) as Spec;
const schemas = spec.components?.schemas ?? {};

const objectSchemas = Object.entries(schemas).filter(
  ([, s]) => s.type === "object" && s.properties
);

const blocks = objectSchemas.map(([name, schema]) => generateBlock(name, schema));

const imports = [
  "import gleam/json",
  hasOptionalFields(schemas) ? "import gleam/option.{type Option}" : null,
]
  .filter(Boolean)
  .join("\n");

const content = [
  "// This file is auto-generated from openapi.yaml. Do not edit manually.",
  imports,
  "",
  blocks.join("\n\n"),
  "",
].join("\n");

mkdirSync(dirname(outPath), { recursive: true });
writeFileSync(outPath, content);
console.log(`Generated ${blocks.length} schemas → ${outPath}`);
