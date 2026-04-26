import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { load } from "js-yaml";

const rootDir = join(dirname(fileURLToPath(import.meta.url)), "..");

type Schema = {
  type?: string | string[];
  format?: string;
  properties?: Record<string, Schema>;
  required?: string[];
  items?: Schema;
  $ref?: string;
  minLength?: number;
  maxLength?: number;
  minimum?: number;
  maximum?: number;
  minItems?: number;
  maxItems?: number;
};

type PathItem = {
  requestBody?: {
    content?: {
      "application/json"?: { schema?: Schema };
    };
  };
};

type Spec = {
  components?: { schemas?: Record<string, Schema> };
  paths?: Record<string, PathItem & Record<string, PathItem>>;
};

const refName = (ref: string) => ref.split("/").pop()!;

const toSnakeCase = (s: string) =>
  s.replace(/([A-Z])/g, "_$1").toLowerCase().replace(/^_/, "");

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
      string: schema.format === "date-time" ? "Timestamp" : "String",
      integer: "Int",
      number: "Float",
      boolean: "Bool",
    };
    base = map[scalarType(schema)] ?? "Nil";
  }
  return isRequired && !isNullable(schema) ? base : `Option(${base})`;
}

// --- encoder ---

function encodeExpr(schema: Schema, accessor: string, isRequired: boolean): string {
  const inner = (s: Schema, acc: string): string => {
    if (s.$ref) return `encode_${toSnakeCase(refName(s.$ref))}(${acc})`;
    if (scalarType(s) === "array") {
      const itemEnc = inner(s.items!, "item");
      return `json.array(${acc}, fn(item) { ${itemEnc} })`;
    }
    if (scalarType(s) === "string" && s.format === "date-time") {
      return `json.string(timestamp.to_rfc3339(${acc}, calendar.utc_offset))`;
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
    const shorthand: Record<string, string> = {
      ...(schema.format !== "date-time" ? { string: "json.string" } : {}),
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

function generateEncoderBlock(name: string, schema: Schema): string {
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

// --- decoder ---

// リクエストの date-time は JSON 上は文字列なので String として扱う
function gleamTypeForRequest(schema: Schema, isRequired: boolean): string {
  let base: string;
  if (schema.$ref) {
    base = refName(schema.$ref);
  } else if (scalarType(schema) === "array") {
    base = `List(${gleamTypeForRequest(schema.items!, true)})`;
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

function decoderExpr(schema: Schema): string {
  if (schema.$ref) return `decode_${toSnakeCase(refName(schema.$ref))}()`;
  if (scalarType(schema) === "array") {
    return `decode.list(${decoderExpr(schema.items!)})`;
  }
  const map: Record<string, string> = {
    string: "decode.string",
    integer: "decode.int",
    number: "decode.float",
    boolean: "decode.bool",
  };
  return map[scalarType(schema)] ?? "decode.dynamic";
}

function generateDecoderBlock(name: string, schema: Schema): string {
  const required = new Set(schema.required ?? []);
  const props = Object.entries(schema.properties ?? {});

  const fields = props
    .map(([k, s]) => `    ${toSnakeCase(k)}: ${gleamTypeForRequest(s, required.has(k))}`)
    .join(",\n");

  const typeDef = `pub type ${name} {\n  ${name}(\n${fields},\n  )\n}`;

  const fieldLines = props.map(([k, s]) => {
    const snk = toSnakeCase(k);
    const inner = decoderExpr(s);
    if (!required.has(k) || isNullable(s)) {
      const innerDecoder = isNullable(s) ? `decode.optional(${inner})` : inner;
      return `    use ${snk} <- decode.optional_field("${k}", option.None, ${innerDecoder})`;
    }
    return `    use ${snk} <- decode.field("${k}", ${inner})`;
  });

  const constructorArgs = props
    .map(([k]) => `      ${toSnakeCase(k)}:`)
    .join(",\n");

  const decoderFn =
    `fn decode_${toSnakeCase(name)}(json_string: String) -> Result(${name}, json.DecodeError) {\n` +
    `  json.parse(json_string, {\n` +
    fieldLines.join("\n") + "\n" +
    `    decode.success(${name}(\n${constructorArgs},\n    ))\n` +
    `  })\n}`;

  return `${typeDef}\n\n${decoderFn}`;
}

// --- validator ---

type CheckKind = "min_length" | "max_length" | "min_int" | "max_int" | "min_float" | "max_float" | "date_time";

const checkHelpers: Record<CheckKind, string> = {
  min_length:
    `fn check_min_length(errors: List(String), field: String, value: String, min: Int) -> List(String) {\n` +
    `  case string.length(value) >= min {\n` +
    `    True -> errors\n` +
    `    False -> [field <> " must be at least " <> int.to_string(min) <> " characters", ..errors]\n` +
    `  }\n}`,
  max_length:
    `fn check_max_length(errors: List(String), field: String, value: String, max: Int) -> List(String) {\n` +
    `  case string.length(value) <= max {\n` +
    `    True -> errors\n` +
    `    False -> [field <> " must be at most " <> int.to_string(max) <> " characters", ..errors]\n` +
    `  }\n}`,
  min_int:
    `fn check_min_int(errors: List(String), field: String, value: Int, min: Int) -> List(String) {\n` +
    `  case value >= min {\n` +
    `    True -> errors\n` +
    `    False -> [field <> " must be at least " <> int.to_string(min), ..errors]\n` +
    `  }\n}`,
  max_int:
    `fn check_max_int(errors: List(String), field: String, value: Int, max: Int) -> List(String) {\n` +
    `  case value <= max {\n` +
    `    True -> errors\n` +
    `    False -> [field <> " must be at most " <> int.to_string(max), ..errors]\n` +
    `  }\n}`,
  min_float:
    `fn check_min_float(errors: List(String), field: String, value: Float, min: Float) -> List(String) {\n` +
    `  case value >=. min {\n` +
    `    True -> errors\n` +
    `    False -> [field <> " must be at least " <> float.to_string(min), ..errors]\n` +
    `  }\n}`,
  max_float:
    `fn check_max_float(errors: List(String), field: String, value: Float, max: Float) -> List(String) {\n` +
    `  case value <=. max {\n` +
    `    True -> errors\n` +
    `    False -> [field <> " must be at most " <> float.to_string(max), ..errors]\n` +
    `  }\n}`,
  date_time:
    `fn check_date_time(errors: List(String), field: String, value: String) -> List(String) {\n` +
    `  case timestamp.parse_rfc3339(value) {\n` +
    `    Ok(_) -> errors\n` +
    `    Error(_) -> [field <> " is not a valid date-time", ..errors]\n` +
    `  }\n}`,
};

function collectCheckLines(schema: Schema): { lines: string[]; kinds: Set<CheckKind> } {
  const required = new Set(schema.required ?? []);
  const lines: string[] = [];
  const kinds = new Set<CheckKind>();

  for (const [k, s] of Object.entries(schema.properties ?? {})) {
    // optional フィールドは今回スキップ
    if (!required.has(k) || isNullable(s)) continue;

    const snk = toSnakeCase(k);
    const accessor = `input.${snk}`;
    const st = scalarType(s);

    if (st === "string" && s.format === "date-time") {
      lines.push(`    |> check_date_time("${k}", ${accessor})`);
      kinds.add("date_time");
    }
    if (st === "string" && s.minLength !== undefined) {
      lines.push(`    |> check_min_length("${k}", ${accessor}, ${s.minLength})`);
      kinds.add("min_length");
    }
    if (st === "string" && s.maxLength !== undefined) {
      lines.push(`    |> check_max_length("${k}", ${accessor}, ${s.maxLength})`);
      kinds.add("max_length");
    }
    if (st === "integer" && s.minimum !== undefined) {
      lines.push(`    |> check_min_int("${k}", ${accessor}, ${s.minimum})`);
      kinds.add("min_int");
    }
    if (st === "integer" && s.maximum !== undefined) {
      lines.push(`    |> check_max_int("${k}", ${accessor}, ${s.maximum})`);
      kinds.add("max_int");
    }
    if (st === "number" && s.minimum !== undefined) {
      lines.push(`    |> check_min_float("${k}", ${accessor}, ${s.minimum}.0)`);
      kinds.add("min_float");
    }
    if (st === "number" && s.maximum !== undefined) {
      lines.push(`    |> check_max_float("${k}", ${accessor}, ${s.maximum}.0)`);
      kinds.add("max_float");
    }
  }

  return { lines, kinds };
}

function generateValidatorBlock(name: string, schema: Schema): { block: string; kinds: Set<CheckKind> } | null {
  const { lines, kinds } = collectCheckLines(schema);

  const validateFn =
    `fn validate_${toSnakeCase(name)}(input: ${name}) -> Result(${name}, List(String)) {\n` +
    `  let errors =\n` +
    `    []\n` +
    (lines.length > 0 ? lines.join("\n") + "\n" : "") +
    `  case errors {\n` +
    `    [] -> Ok(input)\n` +
    `    _ -> Error(errors)\n` +
    `  }\n}`;

  const parseFn =
    `pub fn parse_${toSnakeCase(name)}(json_string: String) -> Result(${name}, List(String)) {\n` +
    `  case decode_${toSnakeCase(name)}(json_string) {\n` +
    `    Error(_) -> Error(["invalid request body"])\n` +
    `    Ok(input) -> validate_${toSnakeCase(name)}(input)\n` +
    `  }\n}`;

  return { block: `${validateFn}\n\n${parseFn}`, kinds };
}

// --- helpers ---

function hasOptionalFields(schemas: Record<string, Schema>): boolean {
  return Object.values(schemas).some((schema) => {
    const required = new Set(schema.required ?? []);
    return Object.entries(schema.properties ?? {}).some(
      ([k, s]) => !required.has(k) || isNullable(s)
    );
  });
}

function hasDateTimeFields(schemas: Record<string, Schema>): boolean {
  return Object.values(schemas).some((schema) =>
    Object.values(schema.properties ?? {}).some(
      (s) => scalarType(s) === "string" && s.format === "date-time"
    )
  );
}

function collectRequestSchemaNames(spec: Spec): Set<string> {
  const names = new Set<string>();
  for (const pathItem of Object.values(spec.paths ?? {})) {
    for (const method of ["get", "post", "put", "patch", "delete"] as const) {
      const op = pathItem[method];
      const ref =
        op?.requestBody?.content?.["application/json"]?.schema?.$ref;
      if (ref) names.add(refName(ref));
    }
  }
  return names;
}

// --- main ---

const specPath = join(rootDir, "docs", "openapi.yaml");
const spec = load(readFileSync(specPath, "utf8")) as Spec;
const schemas = spec.components?.schemas ?? {};

const objectSchemas = Object.entries(schemas).filter(
  ([, s]) => s.type === "object" && s.properties
);

// responses.gleam
const requestSchemaNames = collectRequestSchemaNames(spec);
const responseSchemas = objectSchemas.filter(([name]) => !requestSchemaNames.has(name));
const responseBlocks = responseSchemas.map(([name, schema]) => generateEncoderBlock(name, schema));

const responseImports = [
  "import gleam/json",
  hasOptionalFields(Object.fromEntries(responseSchemas)) ? "import gleam/option.{type Option}" : null,
  hasDateTimeFields(Object.fromEntries(responseSchemas)) ? "import gleam/time/calendar" : null,
  hasDateTimeFields(Object.fromEntries(responseSchemas)) ? "import gleam/time/timestamp.{type Timestamp}" : null,
]
  .filter(Boolean)
  .join("\n");

const responsesPath = join(rootDir, "backend", "src", "generated", "responses.gleam");
mkdirSync(dirname(responsesPath), { recursive: true });
writeFileSync(
  responsesPath,
  [
    "// This file is auto-generated from openapi.yaml. Do not edit manually.",
    responseImports,
    "",
    responseBlocks.join("\n\n"),
    "",
  ].join("\n")
);
console.log(`Generated ${responseBlocks.length} response schemas → ${responsesPath}`);

// requests.gleam
const requestSchemas = objectSchemas.filter(([name]) => requestSchemaNames.has(name));

if (requestSchemas.length > 0) {
  const decoderBlocks = requestSchemas.map(([name, schema]) => generateDecoderBlock(name, schema));

  const validatorResults = requestSchemas
    .map(([name, schema]) => generateValidatorBlock(name, schema))
    .filter((r): r is NonNullable<typeof r> => r !== null);

  const allKinds = new Set<CheckKind>(validatorResults.flatMap((r) => [...r.kinds]));
  const validatorBlocks = validatorResults.map((r) => r.block);
  const helperBlocks = [...allKinds].map((k) => checkHelpers[k]);

  const hasOptional = hasOptionalFields(Object.fromEntries(requestSchemas));
  const needsString = allKinds.has("min_length") || allKinds.has("max_length");
  const needsInt = allKinds.has("min_length") || allKinds.has("max_length") || allKinds.has("min_int") || allKinds.has("max_int");
  const needsFloat = allKinds.has("min_float") || allKinds.has("max_float");
  const needsTimestamp = allKinds.has("date_time");

  const requestImports = [
    "import gleam/dynamic/decode",
    needsFloat ? "import gleam/float" : null,
    needsInt ? "import gleam/int" : null,
    "import gleam/json",
    hasOptional ? "import gleam/option.{type Option}" : null,
    needsString ? "import gleam/string" : null,
    needsTimestamp ? "import gleam/time/timestamp" : null,
  ]
    .filter(Boolean)
    .join("\n");

  const requestsPath = join(rootDir, "backend", "src", "generated", "requests.gleam");
  writeFileSync(
    requestsPath,
    [
      "// This file is auto-generated from openapi.yaml. Do not edit manually.",
      requestImports,
      "",
      [...decoderBlocks, ...validatorBlocks, ...helperBlocks].join("\n\n"),
      "",
    ].join("\n")
  );
  console.log(`Generated ${decoderBlocks.length} request schemas → ${requestsPath}`);
}
