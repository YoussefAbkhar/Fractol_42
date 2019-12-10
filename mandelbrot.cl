/*# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    mandelbrot.cl                                      :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: selibrah <marvin@42.fr>                    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2019/12/10 11:07:15 by selibrah          #+#    #+#              #
#    Updated: 2019/12/10 11:09:48 by selibrah         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #*/

// Used to index into the 1D array, so that we can use
// it effectively as a 2D array
int index(int x, int y, int width) {
  return 4*width*y + x*4;
}

// Turn the raw x coordinates [0, 1] into a scaled x coordinate
// [0, 1] -> [-2,2]
double mapX(double x,double Remin, double Remax) {
  return x*(Remax - Remin) + Remin;
}

// Same purpose as mapX
// [0, 1] -> [-2, 2]
double mapY(double y, double Immin, double Immax) {
  return y*(Immax - Immin) + Immin;
}

__kernel void render(__global char *out,double mx,double my,double Remin,double Immin,double Remax,double Immax,int max_iteration) 
{
  int x_dim = get_global_id(0);
  int y_dim = get_global_id(1);
  size_t width = get_global_size(0);
  size_t height = get_global_size(1);
  int idx = index(x_dim, y_dim, width);
  double x_origin = (double)mapX((double) x_dim / width, Remin, Remax);
  double y_origin = (double)mapY((double) y_dim / height, Immin, Immax);

  // The Escape time algorithm, it follows the pseduocode from Wikipedia
  // _very_ closely
  double x = x_origin;
  double y = y_origin;

  int iteration = 0;
    

  // This can be changed, to be more or less precise
  
  double xtemp;
  double ytemp; 
  while(iteration < max_iteration) {
    xtemp = x*x - y*y;
    ytemp = 2*x*y;
    x = xtemp + x_origin;
    y = ytemp + y_origin;
    if(x*x + y*y > 4)
            break;
    iteration++;
  }

  if(iteration == max_iteration) {
    // This coordinate did not escape, so it is in the Mandelbrot set
    out[idx] = 0;
    out[idx + 1] = 0;
    out[idx + 2] = 0;
    out[idx + 3] = 0;
  } else {
    // This coordinate did escape, so color based on quickly it escaped
    out[idx] = (iteration)*4;
    out[idx + 1] = (iteration)*3;
    out[idx + 2] = iteration*2;
    out[idx + 3] = 0;
  }

}