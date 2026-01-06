## How to Run

1. run ./install_sglang_cpu.sh to install sglang
2. run ./enter_sglang_uv_and_clone_eval.sh to enter the virtual environment and clone the evaluation repository
3. cd /sgl-workspace/multi-model-process-eval/scripts/embedding/sglang
4. ./start_sglang_server.sh to start the sglang server
5. start a new terminal
  * cd /sgl-workspace/multi-model-process-eval/scripts/embedding/sglang
  * SYNTHETIC_TOKEN_LEN=20 BACKEND=sglang ./run_fix_token_len.sh

Note: You should '''SYNTHETIC_TOKEN_LEN=20 BACKEND=sglang ./run_fix_token_len.sh''' to run twice and the second time is the right result.