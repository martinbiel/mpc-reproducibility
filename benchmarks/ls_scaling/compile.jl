using DABenchmarks

ls_scaling = load_results("ls_scaling_1.json", Val{:scaling}())
ls_scaling.results["2"] = load_results("ls_scaling_2.json", Val{:scaling}()).results["2"]
ls_scaling.results["4"] = load_results("ls_scaling_4.json", Val{:scaling}()).results["4"]
ls_scaling.results["8"] = load_results("ls_scaling_8.json", Val{:scaling}()).results["8"]
ls_scaling.results["16"] = load_results("ls_scaling_16.json", Val{:scaling}()).results["16"]
save_results!(ls_scaling, "ls_scaling.json")
