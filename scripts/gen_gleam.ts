import type { Spec } from "./gleam/types.ts";
import {
  hasOptionalFields,
  hasDateTimeFields,
  collectRequestSchemaNames,
} from "./gleam/utils.ts";
import { generateEncoderBlock } from "./gleam/encoder.ts";
import { generateDecoderBlock } from "./gleam/decoder.ts";
import { checkHelpers, generateValidatorBlock } from "./gleam/validator.ts";
import type { CheckKind } from "./gleam/validator.ts";


const jsonPath = process.argv[2]!;
const spec = await Bun.file(jsonPath).json() as Spec;
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

const responsesPath = new URL("../backend/src/generated/responses.gleam", import.meta.url).pathname;
await Bun.write(
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

  const validatorResults = requestSchemas.map(([name, schema]) =>
    generateValidatorBlock(name, schema)
  );

  const allKinds = new Set<CheckKind>(validatorResults.flatMap((r) => [...r.kinds]));
  const validatorBlocks = validatorResults.map((r) => r.block);
  const helperBlocks = [...allKinds].map((k) => checkHelpers[k]);

  const hasOptional = hasOptionalFields(Object.fromEntries(requestSchemas));
  const needsString = allKinds.has("min_length") || allKinds.has("max_length");
  const needsInt =
    allKinds.has("min_length") ||
    allKinds.has("max_length") ||
    allKinds.has("min_int") ||
    allKinds.has("max_int");
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

  const requestsPath = new URL("../backend/src/generated/requests.gleam", import.meta.url).pathname;
  await Bun.write(
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
