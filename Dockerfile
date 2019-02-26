FROM  julia:1.0.2
RUN   apt-get update
RUN   apt-get install -y python3 libgmp-dev
COPY  DABenchmarks $HOME/DABencmarks
COPY  data $HOME/data
COPY  general $HOME/general
COPY  benchmarks $HOME/benchmarks
COPY  benchmark_results $HOME/benchmark_results
COPY  Project.toml /root/.julia/environments/v1.0/
COPY  Manifest.toml /root/.julia/environments/v1.0/
RUN   julia --eval 'using Pkg;\
		    pkg"instantiate";\
		    pkg"precompile";'
