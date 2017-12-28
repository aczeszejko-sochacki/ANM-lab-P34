# Aleksander Czeszejko-Sochacki
# Slawomir Gorawski


@enum METHOD nearest_neighbours linear_spline cubic_spline
@enum ORIENTATION horizontal vertical


# HELPER FUNCTIONS
# 1-dimensional image expansion

function expand_using_nearest_neighbours(img::Matrix, new_x::Int)
    old_y, old_x = size(img)
    new_img = Matrix{Float64}(old_y, new_x)
    
    for x = 1:new_x
        # Creating entire columns at once for simplicity
        new_img[:, x] = map(1:old_y) do y
            p = 1 + (x-1)*(old_x-1) / (new_x-1)
            img[y, Int(round(p))]
        end
    end
    new_img
end


function expand_using_linear_spline(img::Matrix, new_x::Int)
    old_y, old_x = size(img)
    new_img = Matrix{Float64}(old_y, new_x)
    
    # Lagrange-style linear interpolation
    lin_spline_val(x, x0, x1, y0, y1) = y0 * (x-x1)/(x0-x1) + y1 * (x-x0)/(x1-x0)
    
    for x = 1:new_x
        # Creating entire columns at once for simplicity
        new_img[:, x] = map(1:old_y) do y
            p = 1 + (x-1)*(old_x-1) / (new_x-1)
            x0 = Int(floor(p))
            x1 = Int(ceil(p))
            
            # Guard to avoid zero division
            if x0 == x1
                img[y, Int(p)]
            else
                lin_spline_val(p, x0, x1, img[y, x0], img[y, x1])
            end
        end
    end
    new_img
end


function expand_using_cubic_spline(img::Matrix, new_x::Int)
    #
    # TODO implement functionality
    #
    img
end


# MAIN FUNCTION
# Expands image twice using functions defined above

function resize(img::Matrix, new_x::Int, new_y::Int,
                method::METHOD, first_orientation::ORIENTATION)
    
    # Mapping enums to actual functions
    if method == nearest_neighbours
        transformation = expand_using_nearest_neighbours
    elseif method == linear_spline
        transformation = expand_using_linear_spline
    elseif method == cubic_spline
        transformation = expand_using_cubic_spline
    else
        throw(ArgumentError("Method not recognized"))
    end
    
    # Image transposition to reverse expansion order
    first_orientation == vertical && (img = img')
    
    new_img = transformation(img, new_x)'
    new_img = transformation(new_img, new_y)'
    
    first_orientation == vertical && (new_img = new_img')
    
    new_img
end
