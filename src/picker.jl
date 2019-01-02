function pick_lines(t::AbstractVector{Float64}, X::Matrix{Float64})
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
        lines!(scene, t, X[:,i])
    end
    on(linewidths) do lw
        for i in 1:length(lw)
            push!(scene.plots[i+1][:linewidth],lw[i])
        end
    end

    scene
end
