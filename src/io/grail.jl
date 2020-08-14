"""
Loads a Grail json document and converts it into the petroleumModels data structure
"""
function parse_grail(network_file::AbstractString, time_series_file::AbstractString; time_point = 1, slack_producers = false)
    network_data = open(network_file, "r") do io
        JSON.parse(io)
    end

    profile_data = open(time_series_file, "r") do io
        JSON.parse(io)
    end

    @assert length(profile_data["time_points"]) >= time_point

    p_nodes = Dict([(node["index"], node) for node in network_data["node"]])
    p_edges = Dict([(edge["index"], edge) for edge in network_data["edge"]])
    p_pumps = Dict([(pump["index"], pump) for pump in network_data["pump"]])

    p_node_withdrawal = Dict{Int,Any}()
    for (i, withdrawal) in enumerate(profile_data["withdrawal"])
        # based on connectivity, this appears to be node index keys (not node id keys)
        junction_id = withdrawal["node_index"]
        withdrawal_value = withdrawal["withdrawal"][time_point]

        # FOLLOW UP: make sure this is the correct interpretation of multiple withdrawal
        if withdrawal_value != 0.0
            if !haskey(p_node_withdrawal, junction_id)
                p_node_withdrawal[junction_id] = [withdrawal_value]
            else
                push!(p_node_withdrawal[junction_id], withdrawal_value)
            end
        end
    end

    pm_junctions = Dict{String,Any}()
    pm_producers = Dict{String,Any}()
    pm_consumers = Dict{String,Any}()

    producer_count = 1
    consumer_count = 1

    node_id_to_junction_id = Dict{Int,Int}()
    for (i, node) in p_nodes
        node_id_to_junction_id[node["index"]] = node["node"]

        junction_id = node["node"]

        pm_junction = Dict{String,Any}(
            "index" => junction_id,
            "Hmax" => node["Hmax"],
            "Hmin" =>  node["Hmin"],
            "z" => node["z"]
        )

        junction_index = "$(pm_junction["index"])"
        @assert !haskey(pm_junctions, junction_index)
        pm_junctions[junction_index] = pm_junction

        if haskey(p_node_withdrawal, node["index"])
            for withdrawal in p_node_withdrawal[node["index"]]
                if withdrawal > 0
                    #=
                    pm_consumer = Dict{String,Any}(
                        "index" => consumer_count,
                        "ql_junc" => junction_id,
                        "qlmax" => 0.0,
                        "qlmin" => 0.0,
                        "ql" => withdrawal
                    )
                    =#

                    pm_consumer = Dict{String,Any}(
                        "index" => consumer_count,
                        "ql_junc" => junction_id,
                        "qlmax" => withdrawal,
                        "qlmin" => 0.0,
                        "ql" => 0.0
                    )


                    consumer_index = "$(pm_consumer["index"])"
                    @assert !haskey(pm_consumers, consumer_index)
                    pm_consumers[consumer_index] = pm_consumer
                    consumer_count += 1
                else
                    #=
                    pm_producer = Dict{String,Any}(
                        "index" => producer_count,
                        "qg_junc" => junction_id,
                        "qpmax" => 0.0,
                        "qpmin" => 0.0,
                        "qg" => -withdrawal
                    )
                    =#

                    pm_producer = Dict{String,Any}(
                        "index" => producer_count,
                        "qg_junc" => junction_id,
                        "qpmax" => -withdrawal,
                        "qpmin" => 0.0,
                        "qg" => 0.0
                    )

                    producer_index = "$(pm_producer["index"])"
                    @assert !haskey(pm_producers, producer_index)
                    pm_producers[producer_index] = pm_producer
                    producer_count += 1
                end
            end
        end

        if node["isslack"] != 0 && slack_producers
            Memento.warn(_LOGGER,"adding producer at junction $(junction_id) to model slack capacity")

            pm_producer = Dict{String,Any}(
                "index" => producer_count,
                "qg_junc" => junction_id,
                "qpmax" => node["qmax"],
                "qpmin" => node["qmin"],
                "qg" => 0.0
            )

            producer_index = "$(pm_producer["index"])"
            @assert !haskey(pm_producers, producer_index)
            pm_producers[producer_index] = pm_producer
            producer_count += 1
        end

    end

    #println(length(pm_junctions))
    #println(length(pm_producers))
    #println(length(pm_consumers))

    pm_connections = Dict{String,Any}()
    for (i, edge) in p_edges
        @assert edge["fr_node"] == node_id_to_junction_id[edge["f_id"]]
        @assert edge["to_node"] == node_id_to_junction_id[edge["t_id"]]

        # assume diameter units in inches, convert to meters
        # assume length units is in degrees, convert to meters
        #
        # length = max(edge["length"], 0.1) # to be robust to zero values
        # c = 96.074830e-15            # petroleum relative constant
        # L = length*54.0*1.6          # length of the pipe [km]
        # D = edge["diameter"]*25.4    # interior diameter of the pipe [mm]
        # T = 281.15                   # petroleum temperature [K]
        # epsilon = 0.05               # absolute rugosity of pipe [mm]
        # delta = 0.6106               # density of the petroleum relative to air [-]
        # z = 0.8                      # petroleum compressibility factor [-]
        # B = 3.6*D/epsilon
        # lambda = 1/((2*log10(B))^2)
        # resistance = c*(D^5/(lambda*z*T*L*delta));
        #
        # resistance = max(resistance, 0.01) # to have numerical robustness
# pipe
        pm_connection = Dict{String,Any}(
            "index" => edge["index"],
            "fr_junction" => edge["fr_node"],
            "to_junction" =>  edge["to_node"],
            "length" => L,
            "diameter" => D,
            "Qmin" => Qmin,
            "Qmax" => Qmax,
            "type" => "pipe"
        )

        # if pm_connection["friction_factor"] == 0.0
        #     pm_connection["type"] = "short_pipe"
        # end

        connection_index = "$(pm_connection["index"])"
        @assert !haskey(pm_connections, connection_index)
        pm_connections[connection_index] = pm_connection
    end

    #println(length(pm_connections))


    max_junction_id = maximum([junction["index"] for (i,junction) in pm_junctions])
    junction_id_offset = trunc(Int, 10^ceil(log10(max_junction_id)))
    #println(max_junction_id)
    #println(junction_id_offset)

# pump
    pump_offset = maximum(connection["index"] for (i,connection) in pm_connections)
    pump_count = 1
    for (i, pump) in p_pumps
        @assert pump["node"] == node_id_to_junction_id[pump["node_id"]]

        # prepare a new junction for the pipe-connecting pump
        fr_junction = pm_junctions["$(pump["node"])"]
        to_junction_index = junction_id_offset + fr_junction["index"]

        Memento.warn(_LOGGER,"adding junction $(to_junction_index) to capture both sides of a pump")

        pm_junction = Dict{String,Any}(
            "index" => junction_id,
            "Hmax" => node["Hmax"],
            "Hmin" =>  node["Hmin"],
            "z" => node["z"]
        )

        junction_index = "$(pm_junction["index"])"
        @assert !haskey(pm_junctions, junction_index)
        pm_junctions[junction_index] = pm_junction
# pipe
        # update pipe to point to new junction
        pipe = pm_connections["$(pump["edge_id"])"]
        @assert pipe["type"] == "pipe"
        @assert pipe["to_junction"] == pump["node"] || pipe["fr_junction"] == pump["node"]

        # FOLLOW UP: this could be an indication of a pump orientation issue
        if pipe["fr_junction"] == pump["node"]
            pipe["fr_junction"] = to_junction_index
        else
            pipe["to_junction"] = to_junction_index
        end
# pump
        pump_index = pump_offset + pump_count

        pm_connection = Dict{String,Any}(
            "index" => pump_index,
            "fr_junction" => pump["node"],
            "to_junction" => to_junction_index,
            "delta_Hmax" => pump["delta_Hmax"],
            "delta_Hmin" => pump["delta_Hmin"],
            "type" => "pump",

        )

        # @assert pump["cmin"] >= 1.0

        connection_index = "$(pm_connection["index"])"
        @assert !haskey(pm_connections, connection_index)
        pm_connections[connection_index] = pm_connection

        pump_count += 1
    end

    pm_network = Dict{String,Any}(
        "name" => split(network_file,'.')[1],
        "multinetwork" => false,
        "junction" => pm_junctions,
        "producer" => pm_producers,
        "consumer" => pm_consumers,
        "connection" => pm_connections
    )

    #println("total production = $(sum([producer["qg"] for (i,producer) in pm_producers]))")
    #println("total consumption = $(sum([consumer["qlfirm"] for (i,consumer) in pm_consumers]))")

    return pm_network
end
