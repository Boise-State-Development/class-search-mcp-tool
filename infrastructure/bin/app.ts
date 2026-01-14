#!/usr/bin/env node
import "source-map-support/register";
import * as cdk from "aws-cdk-lib";
import { McpLambdaStack } from "../lib/mcp-lambda-stack";
import { loadConfig } from "../lib/config";

const app = new cdk.App();

// Load configuration
const config = loadConfig(app);

// Determine AWS account and region
const account =
  config.awsAccountId || process.env.CDK_DEFAULT_ACCOUNT || undefined;
const region = config.awsRegion || process.env.CDK_DEFAULT_REGION || "us-west-2";

// Create the MCP Lambda stack
new McpLambdaStack(app, `${config.projectPrefix}-stack`, {
  config,
  env: {
    account,
    region,
  },
  description: "MCP Docker Lambda Template - Containerized MCP tool on Lambda",
  tags: {
    Project: config.projectPrefix,
    ManagedBy: "CDK",
  },
});

app.synth();
