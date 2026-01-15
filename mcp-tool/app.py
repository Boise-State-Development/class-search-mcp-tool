"""
MCP Tool - Current Time Server

A simple MCP server that provides the current time.
This serves as a template for building MCP tools that run in AWS Lambda.
"""

import os
from datetime import datetime, timezone
from zoneinfo import ZoneInfo

from mcp.server.fastmcp import FastMCP

# Initialize the MCP server in stateless mode for Lambda compatibility
mcp = FastMCP(
    name="time-server",
    instructions="A simple MCP server that returns the current time in various formats and timezones.",
    stateless_http=True,  # Required for Lambda/serverless environments
)


@mcp.tool()
def get_current_time(timezone_name: str = "UTC") -> dict:
    """
    Get the current time in the specified timezone.

    Args:
        timezone_name: The timezone name (e.g., 'UTC', 'America/New_York', 'Europe/London').
                      Defaults to 'UTC'.

    Returns:
        A dictionary containing the current time in various formats.
    """
    try:
        tz = ZoneInfo(timezone_name)
    except Exception:
        tz = timezone.utc
        timezone_name = "UTC"

    now = datetime.now(tz)

    return {
        "timezone": timezone_name,
        "iso8601": now.isoformat(),
        "unix_timestamp": int(now.timestamp()),
        "formatted": now.strftime("%Y-%m-%d %H:%M:%S %Z"),
        "date": now.strftime("%Y-%m-%d"),
        "time": now.strftime("%H:%M:%S"),
        "day_of_week": now.strftime("%A"),
    }


@mcp.tool()
def get_time_difference(timezone1: str = "UTC", timezone2: str = "America/New_York") -> dict:
    """
    Get the time difference between two timezones.

    Args:
        timezone1: The first timezone (default: UTC)
        timezone2: The second timezone (default: America/New_York)

    Returns:
        A dictionary containing the current time in both timezones and the offset.
    """
    try:
        tz1 = ZoneInfo(timezone1)
    except Exception:
        tz1 = timezone.utc
        timezone1 = "UTC"

    try:
        tz2 = ZoneInfo(timezone2)
    except Exception:
        tz2 = timezone.utc
        timezone2 = "UTC"

    now_utc = datetime.now(timezone.utc)
    time1 = now_utc.astimezone(tz1)
    time2 = now_utc.astimezone(tz2)

    offset1 = time1.utcoffset().total_seconds() / 3600
    offset2 = time2.utcoffset().total_seconds() / 3600
    difference = offset2 - offset1

    return {
        "timezone1": {
            "name": timezone1,
            "time": time1.strftime("%Y-%m-%d %H:%M:%S %Z"),
            "utc_offset_hours": offset1,
        },
        "timezone2": {
            "name": timezone2,
            "time": time2.strftime("%Y-%m-%d %H:%M:%S %Z"),
            "utc_offset_hours": offset2,
        },
        "difference_hours": difference,
    }


# Create the Starlette app for HTTP transport
app = mcp.streamable_http_app()


def lambda_handler(event, context):
    """
    AWS Lambda handler function.
    Uses Mangum to adapt the ASGI app for Lambda.
    """
    from mangum import Mangum

    # Use lifespan="auto" to allow MCP session manager to initialize
    handler = Mangum(app, lifespan="auto")
    return handler(event, context)


if __name__ == "__main__":
    import uvicorn

    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)
