###############################################################################
###############################################################################
### Definition and constructors
###############################################################################
###############################################################################

@doc Markdown.doc"""
   PolyhedralFan(Rays, Cones)

A polyhedral fan formed from rays and cones made of these rays. The cones are
given as an IncidenceMatrix, where the columns represent the rays and the rows
represent the cones. There is a 1 at position (i,j) if cone i has ray j as
extremal ray, otherwise there is a 0.
"""
struct PolyhedralFan
   pm_fan::Polymake.BigObject
   function PolyhedralFan(pm::Polymake.BigObject)
      return new(pm)
   end
end
function PolyhedralFan(Rays::Union{Oscar.MatElem,AbstractMatrix}, Incidence::IncidenceMatrix)
   arr = @Polymake.convert_to Array{Set{Int}} Polymake.common.rows(Incidence.pm_incidencematrix)
   PolyhedralFan(Polymake.fan.PolyhedralFan{Polymake.Rational}(
      INPUT_RAYS = matrix_for_polymake(Rays),
      INPUT_CONES = arr,
   ))
end
function PolyhedralFan(Rays::Union{Oscar.MatElem,AbstractMatrix}, LS::Union{Oscar.MatElem,AbstractMatrix}, Incidence::IncidenceMatrix)
   arr = @Polymake.convert_to Array{Set{Int}} Polymake.common.rows(Incidence.pm_incidencematrix)
   PolyhedralFan(Polymake.fan.PolyhedralFan{Polymake.Rational}(
      INPUT_RAYS = matrix_for_polymake(Rays),
      INPUT_LINEALITY = matrix_for_polymake(LS),
      INPUT_CONES = arr,
   ))
end

"""
   pm_fan(PF::PolyhedralFan)

Get the underlying polymake object, which can be used via Polymake.jl.
"""
pm_fan(PF::PolyhedralFan) = PF.pm_fan


function PolyhedralFan(itr)
   cones = collect(Cone, itr)
   BigObjectArray = Polymake.Array{Polymake.BigObject}(length(cones))
   for i in 1:length(cones)
      BigObjectArray[i] = pm_cone(cones[i])
   end
   PolyhedralFan(Polymake.fan.check_fan_objects(BigObjectArray))
end



#Same construction for when the user gives Array{Bool,2} as incidence matrix
function PolyhedralFan(Rays::Union{Oscar.MatElem,AbstractMatrix}, LS::Union{Oscar.MatElem,AbstractMatrix}, Incidence::Array{Bool,2})
   PolyhedralFan(Rays, LS, IncidenceMatrix(Polymake.IncidenceMatrix(Incidence)))
end
function PolyhedralFan(Rays::Union{Oscar.MatElem,AbstractMatrix}, Incidence::Array{Bool,2})
   PolyhedralFan(Rays,IncidenceMatrix(Polymake.IncidenceMatrix(Incidence)))
end

###############################################################################
###############################################################################
### Display
###############################################################################
###############################################################################
function Base.show(io::IO, PF::PolyhedralFan)
    print(io, "A polyhedral fan in ambient dimension $(ambient_dim(PF))")
end

###############################################################################
###############################################################################
### Iterators
###############################################################################
###############################################################################

struct PolyhedralFanRayIterator
    fan::PolyhedralFan
end

function Base.iterate(iter::PolyhedralFanRayIterator, index = 1)
    rays = pm_fan(iter.fan).RAYS
    if size(rays, 1) < index
        return nothing
    end

    return (rays[index, :], index + 1)
end
Base.eltype(::Type{PolyhedralFanRayIterator}) = Polymake.Vector{Polymake.Rational}
Base.length(iter::PolyhedralFanRayIterator) = nrays(iter.fan)

"""
   rays(PF::PolyhedralFan)

Returns the rays of a polyhedral fan.
"""
rays(PF::PolyhedralFan) = PolyhedralFanRayIterator(PF)


"""
   maximal_cones(PF::PolyhedralFan)

Returns the maximal cones of a polyhedral fan.
"""

#TODO: should the documentation mention maximal_cones_as_incidence_matrix?
#      similarly for cone ray iterators and facet iterators?
@doc Markdown.doc"""
   maximal_cones(PF::PolyhedralFan, as = :cones)

Returns an iterator over the maximal cones of the polyhedral fan `PF`.
"""
function maximal_cones(PF::PolyhedralFan)
   MaximalConeIterator(PF)
end

struct MaximalConeIterator
    PF::PolyhedralFan
end

function Base.iterate(iter::MaximalConeIterator, index = 1)
    n_max_cones = nmaximal_cones(iter.PF)
    if index > n_max_cones
        return nothing
    end
    current_cone = Cone(Polymake.fan.cone(pm_fan(iter.PF), index - 1))
    return (current_cone, index + 1)
end
Base.length(iter::MaximalConeIterator) = nmaximal_cones(iter.PF)

###############################################################################
###############################################################################
### Access properties
###############################################################################
###############################################################################

###############################################################################
## Scalar properties
###############################################################################

"""
   dim(PF::PolyhedralFan)

Returns the dimension of a polyhedral fan.
"""
dim(PF::PolyhedralFan) = pm_fan(PF).FAN_DIM

"""
   nmaximal_cones(PF::PolyhedralFan)

Returns the number of maximal cones in a polyhedral fan `PF`.
"""
nmaximal_cones(PF::PolyhedralFan) = pm_fan(PF).N_MAXIMAL_CONES

"""
   ambient_dim(PF::PolyhedralFan)

Returns the ambient dimension of a polyhedral fan, which is the dimension of
the embedding space. This is equal to the dimension of the fan if the fan is
full-dimensional.
"""
ambient_dim(PF::PolyhedralFan) = pm_fan(PF).FAN_AMBIENT_DIM

"""
   nrays(PF::PolyhedralFan)

Returns the number of rays of a polyhedral fan.
"""
nrays(PF::PolyhedralFan) = pm_fan(PF).N_RAYS


###############################################################################
## Points properties
###############################################################################

"""
   lineality_space(PF::PolyhedralFan)

Returns the lineality_space of a polyhedral fan.
"""
lineality_space(PF::PolyhedralFan) = pm_fan(PF).LINEALITY_SPACE


"""
   rays_as_point_matrix(PF::PolyhedralFan)

Returns the rays of a polyhedral fan as rows of a matrix.
"""
rays_as_point_matrix(PF::PolyhedralFan) = pm_fan(PF).RAYS


"""
   maximal_cones_as_incidence_matrix(PF::PolyhedralFan)

Returns the maximal cones of a polyhedral fan as an incidence matrix where the
rows correspond to the maximal cones and the columns to the rays.
"""
function maximal_cones_as_incidence_matrix(PF::PolyhedralFan)
   IncidenceMatrix(pm_fan(PF).MAXIMAL_CONES)
end

###############################################################################
## Boolean properties
###############################################################################
"""
   issmooth(PF::PolyhedralFan)

Determine whether the fan is smooth.
"""
issmooth(PF::PolyhedralFan) = pm_fan(PF).SMOOTH_FAN

"""
   isregular(PF::PolyhedralFan)

Determine whether the fan is regular, i.e. the normal fan of a polytope.
"""
isregular(PF::PolyhedralFan) = pm_fan(PF).REGULAR

"""
   iscomplete(PF::PolyhedralFan)

Determine whether the fan is complete.
"""
iscomplete(PF::PolyhedralFan) = pm_fan(PF).COMPLETE

#TODO: inward/outward options? via polymake changes?

"""
   normal_fan(P::Polyhedron)

Returns the normal fan of a polyhedron.
"""
function normal_fan(P::Polyhedron)
   pmp = pm_polytope(P)
   pmnf = Polymake.fan.normal_fan(pmp)
   return PolyhedralFan(pmnf)
end

"""
   face_fan(P::Polyhedron)

Returns the face fan of a polyhedron.
"""
function face_fan(P::Polyhedron)
   pmp = pm_polytope(P)
   pmff = Polymake.fan.face_fan(pmp)
   return PolyhedralFan(pmff)
end
