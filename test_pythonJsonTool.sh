#!/bin/bash
python3 -m json.tool test_pythonJsonTool.json test_pythonJsonT.json
rm test_pythonJsonTool.json 
mv test_pythonJsonT.json test_pythonJsonTool.json
