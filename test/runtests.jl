using Pkg: Pkg
using Ensembles
using Test
using TestReports
using Aqua
using Documenter

ts = @testset ReportingTestSet "" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(Ensembles; ambiguities=false)
        Aqua.test_ambiguities(Ensembles)
    end

    # Set metadata for doctests.
    DocMeta.setdocmeta!(Ensembles, :DocTestSetup, :(using Ensembles, Test); recursive=true)

    Ensembles.install(:Lorenz63)
    using Lorenz63
    DocMeta.setdocmeta!(
        Ensembles.get_extension(Ensembles, :Lorenz63Ext),
        :DocTestSetup,
        :(using Ensembles, Test);
        recursive=true,
    )

    doctest(Ensembles; manual=true)
    doctest(Base.get_extension(Ensembles, :Lorenz63Ext); manual=true)

    # Run examples.
    examples_dir = joinpath(@__DIR__, "..", "examples")
    for example in readdir(examples_dir)
        if startswith(example, "_")
            continue
        end
        example_path = joinpath(examples_dir, example)
        @show example_path
        orig_project = Base.active_project()
        @testset "Example: $(example)" begin
            if isdir(example_path)
                Pkg.activate(example_path)
                Pkg.develop(; path=joinpath(@__DIR__, ".."))
                Pkg.instantiate()
            end
            script_path = joinpath(example_path, "main.jl")
            try
                include(script_path)
                println("Included script_path")
            finally
                Pkg.activate(orig_project)
            end
        end
    end
end

outputfilename = joinpath(@__DIR__, "..", "report.xml")
open(outputfilename, "w") do fh
    print(fh, report(ts))
end
exit(any_problems(ts))
