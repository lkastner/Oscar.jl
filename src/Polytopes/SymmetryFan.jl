###############################################################################
###############################################################################
### Definition and constructors
###############################################################################
###############################################################################

@doc Markdown.doc"""
    SymmetryFan(Rays, Cones)

    A polyhedral fan formed from the Rays by taking the cones corresponding to
    the indices of the sets in Cones.
"""
struct SymmetryFan
    rays_action::PermGroup
    maximal_cones_action::PermGroup
    rays::Union{Oscar.MatElem,AbstractMatrix}
    rays_representatives::Union{Oscar.MatElem,AbstractMatrix}
    maximal_cone_representatives::IncidenceMatrix
    pm_fan::Polymake.BigObjectAllocated
end


"""
   pm_fan(SF::SymmetryFan)

Get the underlying polymake BigObject.
"""
pm_fan(SF::SymmetryFan) = SF.pm_fan

# If we are given an action on the coordinates
function SymmetryFan(ray_reps::Union{Oscar.MatElem,AbstractMatrix}, maximal_cone_reps::IncidenceMatrix, coordinate_action::PermGroup)
    polymake_gp = PermGroup_to_polymake_array(coordinate_action)
    

end

# If the action permutes the rays
function SymmetryFan(rays::Union{Oscar.MatElem,AbstractMatrix}, maximal_cone_reps::IncidenceMatrix, rays_action::PermGroup)

end
