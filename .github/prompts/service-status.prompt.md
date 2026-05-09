---
mode: agent
description: Check all swarm services on the VM — workers, roamers, vLLM, GPU utilization, and flag anything that needs attention.
---
SSH into `trader@192.168.1.60`. Run the following checks and report:

1. `systemctl list-units 'trading-agent-worker@*' 'trading-agent-roamer@*' --no-pager`
   Report which are active, failed, or inactive.

2. `systemctl is-active vllm telegram-approve viral-pipeline.timer`
   Flag any that are not active.

3. `nvidia-smi --query-gpu=index,memory.used,memory.total,utilization.gpu --format=csv,noheader`
   Flag any GPU with >90% memory usage or >80% utilization.

For each service that should be running but isn't, tell me:
- Which unit failed
- The last 10 lines of its journal (`journalctl -u <unit> -n 10 --no-pager`)
- Recommended action to restore it

Expected active services: `vllm`, `telegram-approve`, `viral-pipeline.timer`, `trading-agent-worker@viral_channel`, `trading-agent-roamer@1`.
Flag anything missing from this list.
