import Base.show

mutable struct ZoomScene
    scene
    fs::Float64
    nlines::Int64
end

Base.display(x, zscene::ZoomScene) = display(x,zscene.scene)

"""
Plots the timeseries represented by `data`, recorded at a sampling rate of `fs` Hz. The optional keyword `nmax` specifies the maximum number of points to draw and thus represents the smallest zoom level. Drag the left slider to center the plot on a time time point. Drag the right slider to zoom in/out. 
"""
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
            push!(scene.plots[2][1],[Point2f0(x,y) for (x,y) in zip(range(_ss1,stop=_ss1+_ss2, length=idx2-idx1+1), data[idx1:idx2])])
            ymin,ymax = extrema(data[idx1:idx2])
            new_limits = FRect(Point2f0(_ss1, ymin), Point2f0(_ss2, ymax-ymin))
            AbstractPlotting.update_limits!(scene, new_limits)
            AbstractPlotting.update!(scene)
        end
    end
    ZoomScene(hbox(vbox(s1,s2),scene),fs, 1)
end

function plot_zoom!(zscene::ZoomScene, data::Vector{T};fs=30_000,timestep=0.1,nmax=100_000) where T <: Real
    fs == zscene.fs || ArgumentError("Signals must be sampled at the same sampling rate")
    s1 = zscene.scene.children[1].children[1]
    s2 = zscene.scene.children[1].children[2]
    scene = zscene.scene.children[2]
    lines!(scene, [0.0], [0.0])[end]
    zscene.nlines += 1
    map(s1[end][:value],s2[end][:value]) do _ss1, _ss2
        idx1 = round(Int64,_ss1*fs+1)
        idx2 = idx1 + round(Int64,_ss2*fs)
        if idx2 <= size(data,1)
            ymin,ymax = extrema(data[idx1:idx2])
            push!(scene.plots[zscene.nlines+1][1],[Point2f0(x,y) for (x,y) in zip(range(_ss1,stop=_ss1+_ss2, length=idx2-idx1+1), data[idx1:idx2])])
            new_limits = FRect(Point2f0(_ss1, ymin), Point2f0(_ss2, ymax-ymin))
            AbstractPlotting.update_limits!(scene, new_limits)
            AbstractPlotting.update!(scene)
        end
    end
    zscene
end
