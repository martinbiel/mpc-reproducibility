using DABenchmarks
using Plots
pyplot()
# L-shaped scaling
ls_scaling = load_results("ls_scaling.json", Val{:scaling}())
p = plot(ls_scaling)
savefig(p,"ls_scaling.pdf")
# L-shaped (TR) bundled scaling
tr_bundle_8 = load_results("tr_bundle_8.json", Val{:bundle}())
p = plot(tr_bundle_8)
savefig(p,"tr_bundle_8.pdf")
# Progressive-hedging scaling
ph_scaling = load_results("ph_scaling.json", Val{:scaling}())
p = plot(ph_scaling, yticks = [1000,2000,3000,4000])
savefig(p,"ph_scaling.pdf")
