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
    new_img = Matrix{Float64}(new_x, old_y)
    
    for y = 1:old_y
        x_values = 1:old_x
        y_values = img[y, :]
        
        spl = Spline1D(x_values, y_values, k=1)
        
        new_y_values = spl.(linspace(1, old_x, new_x))

        new_img[:, y] = new_y_values        
    end
    new_img'
end


function expand_using_cubic_spline(img::Matrix, new_x::Int)
    old_y, old_x = size(img)
    new_img = Matrix{Float64}(new_x, old_y)
    
    for y = 1:old_y
        x_values = 1:old_x
        y_values = img[y, :]
        
        spl = Spline1D(x_values, y_values, k=3)
        
        new_y_values = spl.(linspace(1, old_x, new_x))
        new_y_values = map(x -> x > 1.0 ? 1.0 : x, new_y_values)
        new_y_values = map(x -> x < 0.0 ? 0.0 : x, new_y_values)
        
        new_img[:, y] = new_y_values        
    end
    new_img'
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
