using StochasticPrograms
using LShapedSolvers
using ProgressiveHedgingSolvers
using LaTeXStrings
using Gurobi
using Plots
pyplot()

KTH_colors = [RGB(25/255,84/255,166/255),
              RGB(157/255,16/255,45/255),
              RGB(98/255,146/255,46/255),
              RGB(36/255,160/255,216/255),
              RGB(228/255,54/255,62/255),
              RGB(176/255,201/255,43/255),
              RGB(216/255,84/255,151/255),
              RGB(250/255,185/255,25/255),
              RGB(101/255,101/255,108/255),
              RGB(189/255,188/255,188/255),
              RGB(227/255,229/255,227/255)]

# Model
@info "Constructing farmer problem"
Crops = [:wheat,:corn,:beets]
Purchased = [:wheat,:corn]
Sold = [:wheat, :corn, :beets_quota, :beets_extra]
Cost = Dict(:wheat=>150,:corn=>230,:beets=>260)
Required = Dict(:wheat=>200,:corn=>240,:beets=>0)
PurchasePrice = Dict(:wheat=>238,:corn=>210)
SellPrice = Dict(:wheat=>170, :corn=>150, :beets_quota=>36, :beets_extra=>10)
Budget = 500
@scenario Yield = begin
    wheat::Float64
    corn::Float64
    beets::Float64
end
ξ₁ = YieldScenario(3.0, 3.6, 24.0, probability = 1/3)
ξ₂ = YieldScenario(2.5, 3.0, 20.0, probability = 1/3)
ξ₃ = YieldScenario(2.0, 2.4, 16.0, probability = 1/3)
farmer_model = StochasticModel((Crops,Cost,Budget), (Required,PurchasePrice,SellPrice), (sp)->begin
    @first_stage sp = begin
        (Crops,Cost,Budget) = stage
        @variable(model, x[c = Crops] >= 0)
        @objective(model, Min, sum(Cost[c]*x[c] for c in Crops))
        @constraint(model, sum(x[c] for c in Crops) <= Budget)
    end
    @second_stage sp = begin
        @decision x
        (Required, PurchasePrice, SellPrice) = stage
        ξ = scenario
        @variable(model, y[p = Purchased] >= 0)
        @variable(model, w[s = Sold] >= 0)
        @objective(model, Min, sum( PurchasePrice[p] * y[p] for p = Purchased) - sum( SellPrice[s] * w[s] for s in Sold))

        @constraint(model, const_minreq[p=Purchased],
            ξ[p] * x[p] + y[p] - w[p] >= Required[p])
        @constraint(model, const_minreq_beets,
            ξ[:beets] * x[:beets] - w[:beets_quota] - w[:beets_extra] >= Required[:beets])
        @constraint(model, const_aux, w[:beets_quota] <= 6000)
    end
end)
farmer_problem = instantiate(farmer_model, [ξ₁,ξ₂,ξ₃])
gurobi = GurobiSolver(OutputFlag=0)
optimize!(farmer_problem, solver = gurobi)
Q = optimal_value(farmer_problem)
@info "Solving farmer problem using progressive-hedging"
sm = StochasticPrograms.StructuredModel(farmer_problem, ProgressiveHedgingSolver(gurobi))
sm()
p = plot(sm.Q_history./Q, color_palette = KTH_colors, label="Progressive-hedging", linewidth = 4, xlabel = "Iterations", ylabel = L"\frac{Q_k}{Q^*}")
savefig(p, "farmer_ph.pdf")
@info "Solving farmer problem using L-shaped"
sm = StochasticPrograms.StructuredModel(farmer_problem, LShapedSolver(gurobi))
sm()
p = plot(sm.Q_history./Q, label="L-shaped", color_palette = KTH_colors, linewidth = 4, xlabel = "Iterations", ylabel = L"\frac{Q_k}{Q^*}")
savefig(p, "farmer_ls.pdf")
