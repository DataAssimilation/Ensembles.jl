using Pkg: Pkg
using Ensembles
using Documenter

using Literate

const REPO_ROOT = joinpath(@__DIR__, "..")
const DOC_SRC = joinpath(@__DIR__, "src")
const DOC_STAGE = joinpath(@__DIR__, "stage")
const DOC_BUILD = joinpath(@__DIR__, "build")

# Move src files to staging area.
mkpath(DOC_STAGE)
for (root, dirs, files) in walkdir(DOC_SRC)
    println("Directories in $root: $dirs")
    rel_root = relpath(root, DOC_SRC)
    for dir in dirs
        stage = joinpath(DOC_STAGE, rel_root, dir)
        mkpath(stage)
    end
    println("Files in $root: $files")
    for file in files
        src = joinpath(DOC_SRC, rel_root, file)
        stage = joinpath(DOC_STAGE, rel_root, file)
        cp(src, stage)
    end
end

# Process examples and put them in staging area.
build_examples = true
build_notebooks = true
build_scripts = true
examples = ["Lorenz63" => "lorenz63", "Parallelization" => "parallel"]
examples_extras = ["Example utils" => "_utils/utils.jl"]
examples_markdown = []
examples_extras_markdown = []

function update_header(content, pth)
    links = []
    if build_notebooks
        push!(links, "a [Jupyter notebook](main.ipynb)")
    end
    if build_scripts
        push!(links, "a [plain script](main.jl)")
    end
    if length(links) == 0
        return content
    end
    project_link = "[Project.toml](Project.toml)"
    links_str = join(links, ", ", "$(length(links) > 2 ? "," : "") or ")
    return """
        # **Other formats**: This can also be accessed as $(links_str).
    """ * content
end

mkpath(joinpath(DOC_STAGE, "examples"))
orig_project = Base.active_project()
for (ex, pth) in examples_extras
    in_dir = joinpath(REPO_ROOT, "examples", dirname(pth))
    in_pth = joinpath(REPO_ROOT, "examples", pth)
    out_dir = joinpath(DOC_STAGE, "examples", dirname(pth))

    # Run file.
    if isdir(in_dir)
        Pkg.activate(in_dir)
        Pkg.develop(; path=joinpath(@__DIR__, ".."))
        Pkg.instantiate()
    end
    try
        include(in_pth)
    finally
        Pkg.activate(orig_project)
    end

    root_file = joinpath("examples", dirname(pth), "index.md")
    if isfile(root_file)
        push!(examples_extras_markdown, ex => root_file)
    end

    # Copy files over to out_dir.
    Base.Filesystem.cptree(in_dir, out_dir)
end

for (ex, pth) in examples
    in_dir = joinpath(REPO_ROOT, "examples", pth)
    in_pth = joinpath(in_dir, "main.jl")
    out_dir = joinpath(DOC_STAGE, "examples", pth)
    if build_examples
        push!(examples_markdown, ex => joinpath("examples", pth, "index.md"))
        upd(content) = update_header(content, pth)

        # Copy other files over to out_dir.
        Base.Filesystem.cptree(in_dir, out_dir)

        rm(joinpath(out_dir, "main.jl"))

        if isdir(in_dir)
            Pkg.activate(in_dir)
            Pkg.develop(; path=joinpath(@__DIR__, ".."))
            Pkg.instantiate()
        end
        try
            # Build outputs.
            Literate.markdown(in_pth, out_dir; name="index", preprocess=upd, execute=true)
            if build_notebooks
                Literate.notebook(in_pth, out_dir)
            end
            if build_scripts
                Literate.script(in_pth, out_dir)
            end
        finally
            Pkg.activate(orig_project)
        end
    end
end
append!(examples_markdown, examples_extras_markdown)

# Set metadata for doctests.
DocMeta.setdocmeta!(
    Ensembles, :DocTestSetup, :(using Ensembles, Test, Statistics); recursive=true
)
modules = [Ensembles]

Ensembles.install(:Lorenz63)
using Lorenz63
ext = Base.get_extension(Ensembles, :Lorenz63Ext)
DocMeta.setdocmeta!(ext, :DocTestSetup, :(using Ensembles, Test, Lorenz63); recursive=true)
push!(modules, ext)

Ensembles.install(:EnsembleKalmanFilters)
using EnsembleKalmanFilters
ext = Base.get_extension(Ensembles, :EnsembleKalmanFiltersExt)
DocMeta.setdocmeta!(
    ext, :DocTestSetup, :(using Ensembles, Test, EnsembleKalmanFilters); recursive=true
)
push!(modules, ext)

Ensembles.install(:NormalizingFlowFilters)
using NormalizingFlowFilters
ext = Base.get_extension(Ensembles, :NormalizingFlowFiltersExt)
DocMeta.setdocmeta!(
    ext, :DocTestSetup, :(using Ensembles, Test, NormalizingFlowFilters); recursive=true
)
push!(modules, ext)

using Statistics
ext = Base.get_extension(Ensembles, :StatisticsExt)
DocMeta.setdocmeta!(
    ext, :DocTestSetup, :(using Ensembles, Test, Statistics); recursive=true
)
push!(modules, ext)

makedocs(;
    modules,
    authors="Grant Bruer gbruer15@gmail.com and contributors",
    sitename="Ensembles.jl",
    source=DOC_STAGE,
    build=DOC_BUILD,
    format=Documenter.HTML(;
        repolink="https://github.com/DataAssimilation/Ensembles.jl",
        canonical="https://DataAssimilation.github.io/Ensembles.jl",
        edit_link="main",
        assets=String[],
        size_threshold=2 * 2^20,
    ),
    repo="github.com/DataAssimilation/Ensembles.jl",
    pages=[
        "Home" => "index.md",
        "Examples" => examples_markdown,
        "Coverage" => "coverage/index.md",
    ],
    doctest=false,
    warnonly=true,
)

# Maybe clean up a little.
try
    Pkg.rm("Lorenz63")
    Pkg.rm("EnsembleKalmanFilters")
    Pkg.rm("NormalizingFlowFilters")
catch e
    @warn e
end
