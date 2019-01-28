function plot_zoom(data::Vector{T};fs=30_000,timestep=0.1,nmax=100_000) where T <: Real
    wmax = nmax/fs
    t = range(0.0, step=timestep, stop=(size(data,1)-1)/fs)
    s1,a = AbstractPlotting.textslider(t, "t0", start=first(t))
    s2,b = AbstractPlotting.textslider(range(0.001, step=0.001,stop=wmax), "window", start=timestep)
    scene = Scene()
    lines!(scene, [0.0], [0.0])[end]
    map(scene.events.mousebuttons) do buttons
        if AbstractPlotting.is_mouseinside(scene)
            pos = to_world(scene, Point2f0(scene.events.mouseposition[]))
            if ispressed(scene, Mouse.left)
                if first(t) <= pos[1] <= last(t)
                    push!(s1[end][:value], pos[1])
                end
            elseif ispressed(scene, Mouse.right)
                if first(t) <= pos[1]-s2[end][:value].val <= last(t)
                    push!(s1[end][:value], pos[1] - s2[end][:value].val)
                end
            end
        end
    end
    map(s1[end][:value],s2[end][:value]) do _ss1, _ss2
        idx1 = round(Int64,_ss1*fs+1)
        idx2 = idx1 + round(Int64,_ss2*fs)
        if idx2 <= size(data,1)
            push!(scene.plots[3][1],[Point2f0(x,y) for (x,y) in zip(range(_ss1,stop=_ss1+_ss2, length=idx2-idx1+1), data[idx1:idx2])])
            AbstractPlotting.update_limits!(scene)
            AbstractPlotting.update!(scene)
        end
    end
    hbox(vbox(s1,s2),scene)
end