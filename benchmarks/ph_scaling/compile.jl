using DABenchmarks

ph_scaling = load_results("ph_scaling_1.json", Val{:scaling}())
ph_scaling.results["2"] = load_results("ph_scaling_2.json", Val{:scaling}()).results["2"]
ph_scaling.results["4"] = load_results("ph_scaling_4.json", Val{:scaling}()).results["4"]
ph_scaling.results["8"] = load_results("ph_scaling_8.json", Val{:scaling}()).results["8"]
ph_scaling.results["16"] = load_results("ph_scaling_16.json", Val{:scaling}()).results["16"]
save_results!(ph_scaling, "ph_scaling.json")
