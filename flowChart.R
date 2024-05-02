
library(DiagrammeR)
library(here)

grViz("
      digraph flowchart {
      
      #graph [rankdir = LR]
      
      node [fontname = Helvetica, style = filled]
      
      identified [label = 'Patient is identified \n as smoker \n via EHR', shape = 'oval', fillcolor = 'orange', width=1, height=1]
      
      mailed [label = 'Patient sent a message through EHR portal', shape = 'rectangle', fillcolor = 'lightblue2']  
      
      callClinic [label = 'Patient called by program staff', shape = 'rectangle', fillcolor = 'lightblue2']
      
      clinicVisit [label = 'Patient has telehealth tobacco visit', shape = 'rectangle', fillcolor = 'lightblue2']
      
      ptEnroll [label = 'Patient begins \n program', shape = 'diamond', width=1, height=1]
      
      session1 [label = 'First Smokefree Support session', shape = 'rectangle', fillcolor = 'lightblue2']
      session2to11 [label = 'Sessions 2-11', shape = 'rectangle', fillcolor = 'lightblue2']
      end [label = 'End of program', shape = 'oval', fillcolor = 'orange', width=1, height=1]
      
      medRx [label = 'Medication recommendations \n pended in EHR', shape = 'rectangle', fillcolor = 'lightblue2']
      medReconcile [label = 'Pended recommendation \n ordered by oncology provider', shape = 'rectangle', fillcolor = 'lightblue2']
      medFilledMailed [label = 'Medication filled and mailed \n or provided in clinic', shape = 'rectangle', fillcolor = 'lightblue2']
      
      
      
      identified -> mailed; 
      mailed -> callClinic;
      callClinic -> clinicVisit; 
      clinicVisit -> ptEnroll; 
      ptEnroll -> session1; 
      session1 -> session2to11; 
      session2to11 -> end;
      
      session1 -> medRx; 
      medRx -> medReconcile; 
      medReconcile -> medFilledMailed; 
      medFilledMailed -> end; 
      
      }
      
      ")




# library(magick)
# 
# tmp <- image_read("www/process-map.png")
# 
# img <- image_draw(tmp)
# rect(40, 5, 
#      340, 305, border='red')
# dev.off()
# print(img)




# meetings [label = 'Ongoing meetings \n of involved staff \n and clinicians', shape = 'rectangle', fillcolor = 'lightblue2']
# emergencies [label = 'Manage emergency \n needs as \n required', shape = 'rectangle', fillcolor = 'lightblue2']
