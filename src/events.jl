struct EventsScene
    scene
    sampling_rate
end

Base.display(x,escene::EventsScene) = display(x, escene.scene)

function plot_events(data::Matrix{T}, events::Vector{Int64};fs=30_000.0) where T <: Real
    zscene = plot_zoom(data[1,:],fs=fs)
    lines!(zscene.scene, fill(0.0, 10), range(0.0, stop=0.1,length=10),color="red")
    plot_zoom!(zscene, data[2,:], fs=fs)
    s1 = zscene.scene.children[1].children[1]
    s2 = zscene.scene.children[1].children[2]
    features = permutedims(Float64.(data[:,events]),[2,1])
    fscene = plot_features(features)
    #connect the selected point feature of fscene
    map(fscene.selected_point) do sp
        if 0 < sp <= size(data,2)
            w = s2[end][:value][]
            t0 = events[sp]/fs
            push!(s1[end][:value], t0-w/2.0)
            ymin,ymax = extrema(zscene.scene.children[2][1][:ticks, :ranges][][2])
            push!(zscene.scene.plots[end],[Point2f0(t0,_y) for _y in range(ymin,stop=ymax,length=10)])
        end
    end
    EventsScene(hbox(zscene.scene,fscene.scene),fs)
end
