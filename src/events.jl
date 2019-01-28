struct EventsScene
    scene
    sampling_rate
end

Base.display(x,escene::EventsScene) = display(x, escene.scene)

function plot_events(data::Matrix{T}, events::Vector{Int64};fs=30_000.0) where T <: Real
    zscene = plot_zoom(data[1,:],fs=fs)
    plot_zoom!(zscene, data[2,:], fs=fs)
    s1 = zscene.scene.children[1].children[1]
    features = permutedims(Float64.(data[:,events]),[2,1])
    fscene = plot_features(features)
    #connect the selected point feature of fscene
    map(fscene.selected_point) do sp
        if 0 < sp <= size(data,2)
            push!(s1[end][:value], events[sp]/fs)
        end
    end
    EventsScene(hbox(zscene.scene,fscene.scene),fs)
end
