local parse = require("luasnip").parser.parse_snippet
local snippets = {}
local function add(trigger, description, body)
  snippets[#snippets + 1] = parse({ trig = trigger, name = description, dscr = description, priority = 1100 }, body)
end
add(
  "amain",
  "Async application entry point",
  [=[import asyncio

async def main() -> None:
    ${0:pass}

if __name__ == "__main__":
    asyncio.run(main())]=]
)
add(
  "adef",
  "Typed async function",
  [=[async def ${1:handler}(${2}) -> ${3:None}:
    ${0:pass}]=]
)
add(
  "atest",
  "Async pytest test (pytest-asyncio)",
  [=[import pytest

@pytest.mark.asyncio
async def test_${1:behavior}(${2}) -> None:
    ${0:assert True}]=]
)
add(
  "amock",
  "AsyncMock with a controlled result",
  [=[from unittest.mock import AsyncMock

${1:send_message} = AsyncMock(return_value=${2:None})
$0]=]
)
add(
  "logger",
  "Module logger",
  [=[import logging

logger = logging.getLogger(__name__)
$0]=]
)
add(
  "afix",
  "Async pytest fixture (pytest-asyncio)",
  [=[import pytest_asyncio

@pytest_asyncio.fixture
async def ${1:resource}():
    ${2:resource = None}
    yield resource
    ${0:pass}]=]
)
add(
  "experiment",
  "Reproducible standard-library experiment scaffold",
  [=[import argparse
import json
import random
from pathlib import Path
from time import perf_counter

def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--output", type=Path, default=Path("results.json"))
    args = parser.parse_args()
    rng = random.Random(args.seed)
    started = perf_counter()
    metrics = {"${1:score}": ${2:rng.random()}}
    result = {"seed": args.seed, "seconds": perf_counter() - started, "metrics": metrics}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, indent=2), encoding="utf-8")
    ${0:print(json.dumps(result, indent=2))}

if __name__ == "__main__":
    main()]=]
)
return snippets
