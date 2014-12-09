
#include<pacman_bb_utils.hpp>
#include<pacman_bb.hpp>
#include <boost/concept_check.hpp>

namespace pacman{



// projections are defined as follows
// 0 = xy CObject
// 1 = xz
// 2 = yz

Object2d  Project2plane ( Object3d Object, int plane )
{
  
  Object2d projection; 
  
  for (unsigned int i = 0; i < Object.size(); i++)
  {
    switch (plane)
    {
      case 0:
        projection.push_back(Point2d(Object[i].x(), Object[i].y()));
        break;
      case 1:
        projection.push_back(Point2d(Object[i].x(), Object[i].z()));
        break;
      case 2:
        projection.push_back(Point2d(Object[i].y(), Object[i].z()));
        break;
      default:
        std::cout << "Error" << std::endl;
    }
    
  }
  
 
  return projection;
  
}

Eigen::MatrixXd vec2Eigen(  Object3d& vin )
{

  Eigen::MatrixXd newObject(vin.size(),3);
    
  for (unsigned int i=0; i < vin.size(); i++)
  {
    newObject(i,0) = vin[i].x();
    newObject(i,1) = vin[i].y();
    newObject(i,2) = vin[i].z();
  }
  
  return newObject;
}

Object3d Eigen2cgalvec(  const Eigen::MatrixXd &Mat ){
	
	Object3d res;
	
	for	(unsigned int i = 0; i < Mat.rows(); i++){
		
		res.push_back( Point3d(Mat(i,0), Mat(i,1), Mat(i,2) ) );
		
	}
	
	return res;
}


std::vector<Box> FindBestSplit ( Box Object_in )
{
	
		Object3d Object = Eigen2cgalvec ( Object_in.Points );
    Object2d up, down, left, right;
    double area_up, area_down, area_left, area_right, area_min_y, area_min_x, area_min;
    Point2d cutting_point;
    std::vector<Point2d> cutting_point_vec;
    std::vector<double> area_min_vec;
    std::vector<int> cutting_direction_vec;
    
    
  Object2d face;

  
  for (unsigned int i = 0; i < 3; i++)
  {
      
   switch (i)
    {
      case 0:
        face = Project2plane ( Object, 0); //xy
        break;
      case 1:
        face = Project2plane ( Object, 1);
        break;
      case 2:
        face = Project2plane ( Object, 2);
        break;
    }
    

  K::Iso_rectangle_2 face_bb = CGAL::bounding_box( face.begin(), face.end() );
  double area_total = face_bb.area();
  
  area_min = area_total;
  int cutting_direction = 0;
  
  // Find the best split using horizontal direction
  
  for (unsigned int k = 0; k < face.size(); ++k)
  {    
    
    up.clear();
    down.clear();
    
    for (int t = 0; t < face.size(); ++t)
    {
      if (k==t)
        continue;
      
      if (face[t].y() > face[k].y())
        up.push_back(Point2d(face[t].x(), face[t].y()));
      
      else 
        down.push_back(Point2d(face[t].x() ,face[t].y()));
    }
    
    if (up.size()==0 || down.size()==0)
      continue;
    
    K::Iso_rectangle_2 up_bb = CGAL::bounding_box(up.begin(), up.end());
    K::Iso_rectangle_2 down_bb = CGAL::bounding_box(down.begin(), down.end());
    area_up= up_bb.area();
    area_down= down_bb.area();
    
    if (area_up + area_down < area_min)
    {
      area_min = area_up + area_down;
      cutting_point = face[k];
      cutting_direction = 0;
    }
    
  }

 
  // Find the best split using vertical direction
  
  for (unsigned int k = 0; k < face.size(); ++k)
  {    
    
    right.clear();
    left.clear();
    
    for (int t = 0; t < face.size(); ++t)
    {
      if (k==t)
        continue;
      
      if (face[t].x() > face[k].x())
        right.push_back(Point2d(face[t].x(), face[t].y()));
      
      else 
        left.push_back(Point2d(face[t].x() ,face[t].y()));
      
    }
    
    if (right.size()==0 || left.size()==0)
      continue;
    
    K::Iso_rectangle_2 right_bb = CGAL::bounding_box(right.begin(), right.end());
    K::Iso_rectangle_2 left_bb = CGAL::bounding_box(left.begin(), left.end());
    area_right= right_bb.area();
    area_left= left_bb.area();
    
    if (area_right + area_left < area_min)
    {
      area_min = area_right + area_left;   
      cutting_point = face[k];
      cutting_direction = 1;
    }
    
  }
 
 cutting_point_vec.push_back( cutting_point );
 area_min_vec.push_back(area_min);
 cutting_direction_vec.push_back(cutting_direction);
 
//   std::cout << "Face " << i << std::endl;
//   std::cout << cutting_point << " "; 
//   std::cout << cutting_direction ;
//   std::cout << " " << area_min << " 0 0" <<  std::endl;
  
  }
 

  std::vector<Object3d> test;
  
  double total_area_min = area_min_vec[0];
  int total_min_index = 0, total_min_direction;
  for (unsigned int i; i < cutting_point_vec.size(); i++)
  {
      if( area_min_vec[i] < total_area_min ) 
      {
          total_min_index = i;
      }
      
  }
  
  total_area_min = area_min_vec[total_min_index];
  Point2d best_point = cutting_point_vec[total_min_index];
  total_min_direction = cutting_direction_vec[total_min_index];
  
  Object3d temp_object1, temp_object2;
  for (unsigned int i = 0; i < Object.size(); i++)
  {
      switch (total_min_index)
      {
          case 0:
              if(total_min_direction == 0)
              {
                  if (Object[i].y() >= best_point.y())
                  {
                    temp_object1.push_back(Object[i]);                  
                  }
                  else
                  {
                      temp_object2.push_back(Object[i]);   
                  }
              }
              else
              {
                  if (Object[i].x() >= best_point.x())
                  {
                      temp_object1.push_back(Object[i]);                  
                    }
                    else
                    {
                        temp_object2.push_back(Object[i]);   
                    }
              }
              break;
              
          case 1:
              if(total_min_direction == 0)
              {
                  if (Object[i].z() >= best_point.y())
                  {
                      temp_object1.push_back(Object[i]);                  
                  }
                  else
                  {
                      temp_object2.push_back(Object[i]);   
                  }
              }
              else
              {
                  if (Object[i].x() >= best_point.x())
                  {
                      temp_object1.push_back(Object[i]);                  
                  }
                  else
                  {
                      temp_object2.push_back(Object[i]);   
                  }
              }
              break;
              
          case 2:
              if(total_min_direction == 0)
              {
                  if (Object[i].z() >= best_point.y())
                  {
                      temp_object1.push_back(Object[i]);                  
                  }
                  else
                  {
                      temp_object2.push_back(Object[i]);   
                  }
              }
              else
              {
                  if (Object[i].y() >= best_point.x())
                  {
                      temp_object1.push_back(Object[i]);                  
                  }
                  else
                  {
                      temp_object2.push_back(Object[i]);   
                  }
              }
              break;

            
      }
  }
   
  std::vector <Box> split;
	Box Box1(temp_object1.size());
	Box Box2(temp_object2.size());
	
	Box1.SetPoints( vec2Eigen( temp_object1 ) );
	Box2.SetPoints( vec2Eigen( temp_object2 ) );
	 
	split.push_back( Box1 );
  split.push_back( Box2 );

  
  return split;
  
}


	Box ComputeBoundingBox ( Box Box_in){
	
	Object3d obj_temp = Eigen2cgalvec ( Box_in.Points );
	K::Iso_cuboid_3 c3 = CGAL::bounding_box(obj_temp.begin(), obj_temp.end());
	 
	Eigen::Matrix<double, 2,3> isobox;
	isobox( 0,0 ) = c3.vertex(0).x();
	isobox( 0,1 ) = c3.vertex(0).y();
	isobox( 0,2 ) = c3.vertex(0).z();
	isobox( 1,0 ) = c3.vertex(7).x();
	isobox( 1,1 ) = c3.vertex(7).y();
	isobox( 1,2 ) = c3.vertex(7).z();
	Box_in.Isobox = isobox;
	
	Box_in.Isobox_volume = c3.volume();
	
	return Box_in;
	}

}