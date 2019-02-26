FROM  julia:1.0.2
RUN   apt-get update
RUN   apt-get install -y bzip2
COPY  DABenchmarks $HOME/DABenchmarks
COPY  data $HOME/data
COPY  general $HOME/general
COPY  benchmarks $HOME/benchmarks
COPY  benchmark_results $HOME/benchmark_results
COPY  Project.toml /root/.julia/environments/v1.0/
COPY  Manifest.toml /root/.julia/environments/v1.0/
COPY  fig2.sh $HOME
COPY  fig3.sh $HOME
COPY  fig4.sh $HOME
COPY  fig5.sh $HOME
COPY  fig6.sh $HOME
COPY  plotresults.jl $HOME
RUN   ln -s /usr/local/julia/bin/julia .
RUN   julia --eval 'using Pkg;\
		    pkg"instantiate";\
		    pkg"precompile";'
