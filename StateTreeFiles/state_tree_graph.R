# Create State Tree Diagram

tool_exec<- function(in_params, out_params){
  
  #####################################################################################################  
  ### Check/Load Required Packages  
  #####################################################################################################   
  
  arc.progress_label("Loading packages")
  arc.progress_pos(20)
  
  if(!requireNamespace("igraph", quietly = TRUE))
    install.packages("igraph", quiet = TRUE)
  if(!requireNamespace("sp", quietly = TRUE))
    install.packages("sp", quiet = TRUE)
  
  suppressMessages(require('igraph', quietly = T))
  suppressMessages(require('sp', quietly = T))
  
  #####################################################################################################
  ### Load and arrange data
  #####################################################################################################
  
  # parameters
  temp_folder = in_params[[1]]
  view_window = ifelse(in_params[[2]]=="true", TRUE, FALSE)
  create_features = ifelse(in_params[[3]]=="true", TRUE, FALSE)
  create_pdf = ifelse(in_params[[4]]=="true", TRUE, FALSE)
  
  arc.progress_label("Setting up data")
  arc.progress_pos(25)
  
  state.data <- read.csv(paste0(temp_folder, "\\data.csv"), stringsAsFactors = F)
  state.data$type <- "state"
  
  # extract versions and rearrange as vertices
  version.data <- state.data[state.data$version!="", ]
  version.data <- with(version.data,
                       data.frame(parent=vertex,
                                  vertex=version,
                                  version="",
                                  lineage=lineage,
                                  type="version"))
  
  # add versions to state data
  state.data <- rbind(state.data, version.data)
  
  # dimensions
  n.states = length(unique(state.data$vertex))
  n.versions  = dim(version.data)[1]
  n.verts = n.states + n.versions 
  message("Number of states ", n.states)
  message("Number of versions ", n.versions)
  
  # colors and name for symbology
  state.data$color <- adjustcolor("gray40", alpha.f = 0.2)
  state.data$category <- "Compressible state"
  state.data$color[state.data$version!=""] <- adjustcolor("darkgreen", alpha.f = 0.8)
  state.data$category[state.data$version!=""] <- "Version state"
  state.data$color[state.data$type=="version"] <- adjustcolor("yellow", alpha.f = 0.8)
  state.data$category[state.data$type=="version"] <- "Version"
  state.data$color[state.data$vertex=="DEFAULT"] <- "black"
  state.data$category[state.data$vertex=="DEFAULT"] <- "DEFAULT version"
  state.data$color[state.data$vertex=="0"] <- adjustcolor("black", alpha.f = 0.4)
  state.data$category[state.data$vertex=="0"] <- "State 0"
  # field for label rotation
  state.data$lab_rotation <- 0
  
  # remove extra vertices
  state.data <- state.data[!duplicated(state.data[1:2]), ]
  
  #####################################################################################################
  ### Create igraph network diagram 
  #####################################################################################################
  
  # create igraph graph
  state_diagram <- graph_from_data_frame(state.data[-1, c("parent","vertex")],
                                         vertices = cbind(state.data[2:8]),
                                         directed = T)
  
  # calculate graph coordinates
  arc.progress_label("Rendering diagram")
  arc.progress_pos(30)
  if(n.verts>100000) warning(paste("There are", n.verts,
                                   "vertices. The diagram may take",
                                   "a long time to render.\n"))
  
  state_graph_layout <- layout_as_tree(state_diagram, circular = F)
  
  # graph aspect
  range_x = max(state_graph_layout[, 1]) - min(state_graph_layout[, 1])
  range_y = max(state_graph_layout[, 2]) - min(state_graph_layout[, 2])
  max_range = max(c(range_y, range_x))
  asp = range_y / range_x
  
  # change label rotation if needed
  if(asp < 1) {
    state.data$lab_rotation <- -90
    V(state_diagram)$lab_rotation <- -90
  }
  
  # set aspect factor if out of reasonable bounds
  if (asp < 0.384){
    asp = 0.384
  } else if (asp > 2.6) {
    asp = 2.6
  }
  
  #####################################################################################################
  ### Outputs
  #####################################################################################################
  
  arc.progress_label("Creating outputs")
  arc.progress_pos(60)
  
  if(create_features){
    message("Creating features")
    
    # rescale coordinates to desired aspect
    if (asp > 1){
      scale_y_factor = (max_range/range_y)
      scale_x_factor =(max_range/range_x) * (1/asp)
    } else {
      scale_y_factor = (max_range/range_y) * asp
      scale_x_factor =(max_range/range_x)
    }
    state.data$x <- state_graph_layout[, 1] * scale_x_factor
    state.data$y <- state_graph_layout[, 2] * scale_y_factor
    
    # add coordinates to data
    state.data <- merge(state.data, state.data[c("vertex", "x", "y")],
                        suffixes = c("", "_parent"), by.x="parent",
                        by.y="vertex", sort=FALSE)
    
    # create edge features and save
    edges <- lapply(1:dim(state.data)[1], function(i){
      x <- c(state.data$x[i], state.data$x_parent[i])
      y <- c(state.data$y[i], state.data$y_parent[i])
      Lines(Line(cbind(x,y)), ID=state.data$vertex[i])
    })
    edge.features <- SpatialLinesDataFrame(SpatialLines(edges),
                                           state.data[-c(3,6)],
                                           match.ID=F)
    arc.write(paste0(temp_folder, "\\Relationships.shp"), edge.features)
    
    # vertices to spatial dataframe and save
    coordinates(state.data) <- ~x+y
    arc.write(paste0(temp_folder, "\\Vertices.shp"), state.data[-c(3,6)])
  }
  
  arc.progress_pos(70)
  
  if(view_window){
    if (n.verts > 200000){
      warning("Diagram too large to render in window\n")
    } else{
      message("Rendering in window")
      
      # scale point size for diagram
      point_size <- scale_point_size(n.verts)
      
      # create diagram plot
      plot(state_diagram, layout=state_graph_layout,
           vertex.color=V(state_diagram)$color,
           vertex.label=NA,
           vertex.size=point_size,
           frame=F,
           rescale=T,
           edge.arrow.mode=NA,
           edge.size=point_size*.25,
           asp=asp
      )
      
      legend('topleft', unique(V(state_diagram)$category),
             pt.cex=1.3,
             col=unique(V(state_diagram)$color),
             pch=21, pt.bg= unique(V(state_diagram)$color),
             cex=.7,
             bty = "n"
      )
    }
  }
  
  arc.progress_pos(80)
  
  if(create_pdf){
    if (n.verts > 200000){
      warning("Diagram too large to create pdf")
    } else{
      message("Creating pdf")
      
      # scale point size for diagram
      point_size <- scale_point_size(n.verts)
      
      # label adjustment 
      x_adj = 0
      y_adj = 0
      
      # scale paper size to allow for zooming and aspect correction
      if (asp > 1){
        height = 100
        width = (100 + point_size*10) * (1/asp)
        x_adj = point_size*.012
      } else {
        height = (100 + point_size*10) * asp
        width = 100
        y_adj = -point_size*.018
      }
      
      # path for pdf file
      pdf_file = paste0(temp_folder, "\\diagram.pdf")
      # start pdf file
      pdf(pdf_file, height=height, width=width)
      # create diagram plot
      plot(state_diagram, layout=state_graph_layout,
           vertex.color=V(state_diagram)$color,
           vertex.label=NA,
           vertex.size=point_size,
           vertex.frame.color=ifelse(point_size>0.1,"black",NA),
           frame=F,
           rescale=T,
           edge.arrow.mode=NA,
           edge.width=point_size,
           asp=asp
      )
      legend('topleft', unique(V(state_diagram)$category),
             pt.cex=point_size*4,
             col=unique(V(state_diagram)$color),
             pch=21, pt.bg= unique(V(state_diagram)$color),
             cex=point_size*2,
             bty = "n"
      )
      # manually add labels
      text(x=rescale(state_graph_layout[, 1], -1, 1) + x_adj,
           y=rescale(state_graph_layout[, 2], -1, 1) + y_adj,
           labels=V(state_diagram)$name,
           cex=point_size*.85,
           col="black",
           family="sans",
           srt=V(state_diagram)$lab_rotation[1],
           adj=0
      )
      # end pdf file
      dev.off()
      # open pdf file
      shell(pdf_file, wait=FALSE)
    }
  }
  
  arc.progress_label("Done")  
  arc.progress_pos(100)
  
  out_params[[1]] <- paste0(temp_folder, "\\Vertices.shp")
  out_params[[2]] <- paste0(temp_folder, "\\Relationships.shp")
  return(out_params)
}


#####################################################################################################
### functions
#####################################################################################################


scale_point_size <- function(base_size){
  if(base_size < 15){
    point_size = 10
  } else {
    # fit some test sizes with a linear model on a log, log scale - seems to work.
    point_size = exp(5.1 + -0.9764906*log(base_size))
  } 
  return(point_size)
}

# modified from https://stackoverflow.com/questions/25962508/rescaling-a-variable-in-r
rescale <- function (x, nx1, nx2, minx=min(x), maxx=max(x)) 
{ nx = nx1 + (nx2 - nx1) * (x - minx)/(maxx - minx)
return(nx)
}
