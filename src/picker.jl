type FeatureScene
    scene
    selected_point
end

Base.display(x, fscene::FeatureScene) = display(x, fscene.scene)

function pick_lines(t::AbstractVector{Float64}, X::Matrix{Float64},color=fill(RGB(0.0, 0.0, 0.0), size(X,2)))
    scene = Scene()
    poprect = map(scene.px_area) do pa
        _origin = pa.origin
        width,height = pa.widths
        FRect(_origin + Point2f0(0.1*width, 0.9*height), 0.1*width, 0.1*height)
    end
    textpos = map(poprect) do pr
        _origin = pr.origin
        width,height = pr.widths
        Point2f0(_origin + Point2f0(0.5*width, 0.5*height))
    end
    popup = poly!(campixel(scene), poprect, raw = true, color = :white, strokewidth = 2, strokecolor = :black, visible = true)
    text!(popup, "1", textsize=30, position=textpos, align=(:center,:center), raw=true)
    linewidths = map(scene.events.mousebuttons) do buttons
        if ispressed(scene, Mouse.left)
            pos = to_world(scene, Point2f0(scene.events.mouseposition[]))
            ddm = Inf
            idxm = 1 
            for i in 1:size(X,2)
                _dd = minimum((t .- pos[1]).^2 .+ (X[:,i] .- pos[2]).^2)
                if _dd < ddm
                    ddm = _dd
                    idxm = i
                end
            end
            popup[end][1] =  "$(idxm)"
            lw = fill(1.0, size(X,2))
            lw[idxm] = 5.0
        elseif isopen(scene)
            lw = [scene.plots[i+1][:linewidth].val for i in 1:size(X,2)]

        else
            lw = fill(1.0, size(X,2))
        end
        lw
    end
    for i in 1:size(X,2)
        lines!(scene, t, X[:,i],color=color[i])
    end
    on(linewidths) do lw
        for i in 1:length(lw)
            push!(scene.plots[i+1][:linewidth],lw[i])
        end
    end
    scene
end

"""
Creates a scatter plot of the features in `features` and connects each point to the data in `X`.
"""
function plot_features(X::Matrix{Float64},features::Matrix{Float64},bins=range(0.0,stop=1.0, length=size(X,1));color=fill(parse(Colorant,"black"), size(features,1)))
    mi,mx = extrema(features[:,[1,2]][:])
    ps = 0.05*(mx-mi)  # set pointsize to 1% of the data range
    fscene = scatter(features[:,1], features[:,2],markersize=fill(ps, size(features,1)),color=color)
    xscene = lines(bins, dropdims(mean(X,dims=2),dims=2))
    selected_point = map(fscene.events.mousebuttons) do buttons
        ms = fill(ps, size(features,1))
        if ispressed(fscene, Mouse.left)
            pos = to_world(fscene, Point2f0(fscene.events.mouseposition[]))
            idx = argmin(map(i->(features[i,1] - pos[1])^2 + (features[i,2] - pos[2])^2,1:size(features,1)))
            ms[idx] *= 1.5
            push!(fscene.plots[2][:markersize], ms)
        else
            idx = 0
        end
        idx
    end
    map(selected_point) do ii
        if 0 < ii <= size(X,2)
            xscene.plots[2][2] = X[:,ii]
            push!(xscene.plots[2][:color], color[ii])
            AbstractPlotting.update!(xscene)
            AbstractPlotting.update_limits!(xscene)
        end
    end
    hbox(fscene,xscene)
end

function plot_features(features::Matrix{Float64};color=fill(parse(Colorant,"black"), size(features,1)))
    mi,mx = extrema(features[:,[1,2]][:])
    ps = 0.05*(mx-mi)  # set pointsize to 1% of the data range
    fscene = scatter(features[:,1], features[:,2],markersize=fill(ps, size(features,1)),color=color)
    selected_point = map(fscene.events.mousebuttons) do buttons
        ms = fill(ps, size(features,1))
        if ispressed(fscene, Mouse.left)
            pos = to_world(fscene, Point2f0(fscene.events.mouseposition[]))
            idx = argmin(map(i->(features[i,1] - pos[1])^2 + (features[i,2] - pos[2])^2,1:size(features,1)))
            ms[idx] *= 1.5
            push!(fscene.plots[2][:markersize], ms)
        else
            idx = 0
        end
        idx
    end
    FeatureScene(fscene,selected_point)
end
