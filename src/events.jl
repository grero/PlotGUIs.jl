struct EventScene
    scene
end

Base.display(x,escene::EventScene) = display(x, escene.scene)

function plot_events(data::Matrix{T}, events::Vector{T};fs=30_000.0) where T <: Real
    zscene = plot_zoom(data[:,1],fs=fs)
    plot_zoom!(zsene, data[:,2], fs=fs)
    s1 = zscene.scene.children[1].children[1]
    features = permutedims(data[:,events],[2,1])
    fscene = plot_features(features)
    #connect the selected point feature of fscene
    map(fscene.selected_point) do sp
        push!(s1[:value], events[sp]) 
    end
    EventsScene(hbox(zscene,fscene))
end