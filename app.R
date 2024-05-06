
library(tidyverse)
library(shinydashboard)
library(plotly)
library(reactable)
library(scales)
library(ggsci)
library(shinyWidgets)

# inputs ----
# WAGE VALUES (national averages, from ~2020 BLS wages)
blsWageCounselor <- 22.83*2080
blsWageTrainer <- 66.61*2080
blsWageSupervisor <- 66.61*2080
blsWageProjectDirector <- 66.61*2080
blsWageRAtype <- 23.66*2080
blsWageMD <- 99.7*2080
blsWageNP <- 53.69*2080


jobList <- c("Patient Counselor", 
             "Administrative Staff", 
             "MD", 
             "Counselor Supervisor", 
             "Not Applicable")

names(jobList) <- jobList


# SITE-SPECIFIC INPUTS
# the values used from these datasets will be based on which primary site is selected on the first page of the UI 
# these datasets are NOT able to be modified by the user

# patient retention per session (as a proportion of the initial number recruited into IT)
proportionReturningBySessionMGH <- tribble(~session, ~expectedProportionReturning, 
                                           1, 1,
                                           2, 0.920,
                                           3, 0.770,
                                           4, 0.701,
                                           5, 0.759,
                                           6, 0.632,
                                           7, 0.724,
                                           8, 0.713,
                                           9, 0.690,
                                           10, 0.621,
                                           11, 0.609)



# average time taken per sess
sessionTimesMGH <- tribble(~session, ~preSessionPrep, ~hoursPerSession, ~ehrDocumentation, ~hrsPerSessionPerPatient,
                           1, 0.083, 0.63, 0.125, 0.838,
                           2, 0.083, 0.33, 0.125, 0.538,
                           3, 0.083, 0.3, 0.125, 0.508,
                           4, 0.083, 0.3, 0.125, 0.508,
                           5, 0.083, 0.33, 0.125, 0.538,
                           6, 0.083, 0.32, 0.125, 0.528,
                           7, 0.083, 0.31, 0.125, 0.518,
                           8, 0.083, 0.33, 0.125, 0.538,
                           9, 0.083, 0.31, 0.125, 0.518,
                           10, 0.083, 0.29, 0.125, 0.498,
                           11, 0.083, 0.25, 0.125, 0.458)


expectedMedNumbersPerPatientMGH <- tribble(~med, ~avgMedPerPatient,
                                           "varenStarter",  0.138,
                                           "varenContinuing", 0.172,
                                           "bupropion", 0.149,
                                           "nrtPatch", 1.30,
                                           "nrtLozenge", 1.46)




#if (interactive()) {

dbHeader <- dashboardHeader(title = "SSS CEA Calculator")
dbHeader$children[[2]]$children <-  tags$a(href='https://www.massgeneral.org/mongan-institute/centers/health-policy',
                                           tags$img(src='logo.png',height='60',width='200'))

# ui ----
ui <- dashboardPage(
  
  title = "Smokefree Support Study Cost Calculator",
  
  ## header ----
  dbHeader,
  
  ## sidebar ----
  dashboardSidebar(
    sidebarMenu(
      id = "tabs",
      menuItem("Introduction", tabName="intro", icon = icon("comment")),
      menuItem("Recruitment Estimates", tabName = "input1", icon = icon("list")),
      menuItem("Task Responsibilities", tabName="input2", icon = icon("list")), 
      menuItem("Wages", tabName="input3", icon = icon("list")),
      menuItem("Output", tabName = "output1", icon=icon("chart-bar")),
      menuItem("Reference", tabName="ref", icon = icon("question"))
    ) # end sidebar menu
  ), # end dashboard sidebar
  
  ## body ----
  dashboardBody(
    tabItems(
      
      ### introduction ----
      tabItem(tabName = "intro", 
              box(width=12, h2("Welcome to the Smokefree Support Study cost calculator!")),
              
              tabBox(
                width = 8, 
                tabPanel(title = "About the program",
                         p("The purpose of this tool is to help people like you estimate what it might cost to implement a successful smoking cessation program in your own setting."), 
                         
                         HTML("<p>This program is called the <a href='https://pubmed.ncbi.nlm.nih.gov/33048154/'>Smokefree Support Study</a> and is for patients receiving treatment for cancer. 
                                   The general flow of the program is shown to the right.</p>"),
                         
                         p("This tool takes the results from that trial and allows users to adjust inputs to reflect characteristics of their individual setting such as staffing and patient volume."),
                         
                         p(strong("Key Results:"), "The trial found that 34.5% of patients who received an intensive smoking cessation program quit, while 21.5% of those who received standard smoking cessation guidance quit. 
                    Using existing literature, we expect that an estimated 14.3% of individuals would quit smoking under referral to the state quit line, which we consider to be 'usual care'.")
                ),
                
                tabPanel(title = "More program details", 
                         
                         p(strong("The program:"), "Participants in the program (in the trial it was called 'intensive care') were offered 4 weekly telephone counseling sessions, 
                    4 telephone sessions delivered every-other-week over 2 months, and 3 telephone booster sessions delivered monthly. 
                    The program also included offering participants their choice of 12 weeks of FDA-approved smoking cessation medication at no cost, paid for by the cancer center. 
                    The medication selected by participants was appended as a prescription in the EHR and dispensed (in person or mailed) according to Public Health Service guidelines. 
                    Participants received an initial 4-week supply of FDA-approved smoking cessation medication (varenicline, bupropion sustained release, single or combination nicotine 
                    replacement therapy patch and/or lozenges) with the option of receiving up to 2 additional 4-week supplies."),
                         
                         
                         p("Participants in the comparison group, standard care, were offered 4 weekly telephone counseling sessions plus education and advice regarding cessation medications."),
                         
                         
                         p(strong("Getting started:"), "This calculator is designed to help you and your clinic think through what it might take to implement the Smokefree Support program for cancer patients. On this first page, we are asking you tell us a few things about your cancer center and how the program might be undertaken in your context. It's ok if you don't know exactly - you can always come back and see how your costs might change under different values, scenarios, and contingencies.")
                )
              ), 
              
              box(title = "Flow of Program", 
                  width = 4,
                  img(src = "process-map.png", style = "width: 100%; padding: 0;", align = 'middle')
                  
              )
              
              
      ),
      
      ### reference page ----
      tabItem(tabName = "ref", 
              box(width=12,
              h3("References"), 
              HTML("<p>The results of the original clinical trial were published in the Journal of the American Medical Association in 2020: <a href=https://pubmed.ncbi.nlm.nih.gov/33048154/>https://pubmed.ncbi.nlm.nih.gov/33048154/</a></p>"), 
              HTML("<p>And cost-effectiveness results were published in JAMA Network Open in 2022: <a href=https://pubmed.ncbi.nlm.nih.gov/35679043/>https://pubmed.ncbi.nlm.nih.gov/35679043/</a></p>")
              )), 
      # HTML("<p>Contact a member of the study team at <a href='mailto: xxx@mgh.harvard.edu'>this email</a> with any questions.</p>")), 
      
      
      ### input1 - recruitment ----
      tabItem(tabName = "input1",
              fluidPage(
                box(width=12, 
                    h3("Any of these numbers can be modified to be more specific to your context. It's ok if you don't know exactly - this is just to get started. You can always come back and see how your costs might change under different values.")),
                
                box(title = "Monthly Recruitment Estimates",
                    width=12,
                    
                    #h4("Monthly Recruitment Estimates"),
                    
                    #p("This asks about how many patients you think might be available for screening, eligible, and formally recruited."),
                    
                    h4("How many patients are potentially eligible to receive a smoking cessation program?"), 
                    p("Depending on where you are considering implementing the program, this could - for example - be one clinic or span multiple practices."),
                    numericInput("clinicPatients", NULL, value=500, min=0, step=1, width="20%"),
                    p("Note: If you already have an idea of the number of potentially eligible people who smoke, then you can input that number here and set the next slider to 100%"),
                    
                    tags$br(),
                    
                    h4("Of those patients, what percentage are people who smoke?"), 
                    sliderInput("smokerPatients", NULL, value=12.5, min=0, max=100, step=0.5, width="50%"), 
                    
                    tags$br(),
                    
                    
                    h4("What percentage of those patients do you anticipate inviting to the program?"), 
                    p("Prior work has done this by first mailing introductory letters or sending a message to patients via the EHR system, and then subseqently having tobacco treatment staff call patients."), 
                    p("We suggest leaving this at 100% so that all eligible patients are invited."),
                    sliderInput("eligiblePatients", NULL, value=100, min=0, max=100, step=1, width="50%"),
                    
                    tags$br(),
                    
                    h4("Of those invitations, what percentage do you expect will complete an initial telehealth tobacco visit?"), 
                    p("This is prior to starting the actual Smokefree Support Program."), 
                    sliderInput("patientsTelehealth", NULL, value=80, min=0, max=100, step=1, width="50%"),
                    
                    tags$br(), 
                    
                    h4("Of the patients who do an initial telehealth visit, what percentage do you expect to enroll in the program? (e.g., some may not be interested or available)"), 
                    sliderInput("patientsRecruited", NULL, value=80, min=0, max=100, step=1, width="50%")
                    
                )
              )
      ), 
      
      ### input2 - tasks ----
      tabItem("input2", 
              
              fluidPage(
                
                fluidRow(
                  box(width=12, 
                      h3("Once eligible patients are identified via the EHR, there are a variety of tasks that need to be performed."),
                      p("Now we are going to ask you to identify who might be responsible for each of these tasks."),
                      tags$ul(
                        tags$li("Patient counselor: individual(s) who have been trained to deliver smoking cessation counseling. (examples: social worker, NP)"), 
                        tags$li("Administrative staff: individual(s) who can manage the administrative aspects of the program. (examples: medical assistant, administrative assistant)"), 
                        tags$li("Counselor supervisor: an individual who is in charge of managing patient counselors, addressing administrative issues as needs arise, and keeping the Smokefree Support program running. (examples: nurse manager, MD"), 
                        tags$li("MD: an individual who is able to prescribe medication. (examples: MD, and NP or PA depending on scope of practice)")
                      ), 
                      p("Note that the language we use to describe roles may not match the titles/languaged used in your setting. Please treat these roles as flexible placeholders. You will be able to change the salary to match the specific titles used in your setting associated with each role in the next step.")
                      ),
                ), 
                
                fluidRow(
                  box(title = "Flow of Program", 
                      width = 4,
                      img(src = "process-map.png", style = "width: 100%; padding: 0;", align = 'middle')
                  ),
                  
                  box(title = "Program Tasks", 
                      width=8, 
                      
                      p("We have set the defaults to who we assume would complete these tasks, but all can be changed to align with your context."),
                      
                      p("In some cases, a task might not need to be performed based on the workflow in your clinic, scope of practice laws, or other reasons. If that is the case, please make sure to note this by using the 'Not Applicable' option."),
                      
                      tags$ul(
                        
                        tags$li(h4("Who will send introductory letters?"),
                                selectizeInput("taskMailSmokers", NULL, jobList, width="50%", selected=jobList[[2]], multiple = TRUE, options = list(maxItems = 1))), 
                        
                        tags$li(h4("Who will call potentially-eligible patients?"), 
                                selectizeInput("taskCallSmokers", NULL, jobList, width="50%", selected=jobList[[2]], multiple = TRUE, options = list(maxItems = 1))), 
                        
                        tags$li(h4("Who will conduct the patient's initial telehealth tobacco visit?"), 
                                selectizeInput("taskIntroClinic", NULL, jobList, width="50%", selected=jobList[[1]],  multiple = TRUE, options = list(maxItems = 1))), 
                        
                        tags$li(h4("Who will deliver the telephone cessation counseling?"),
                                p("This includes preparing for the sessions, conducting the sessions, and post-session EHR documentation including 'pending' any smoking cessation medications."),                              
                                selectizeInput("taskCounseling", NULL, jobList, width="50%", selected=jobList[[1]],  multiple = TRUE, options = list(maxItems = 1))), 
                        
                        tags$li(h4("Ordering smoking cessation medication"),
                                p("Will the patient's oncologist have to approve smoking cessation medications?"), 
                                p("In some contexts, medications can be ordered by cessation counselors but have to be approved by a supervising MD."),
                                radioButtons("reconcileYN", NULL, choices = c("yes", "no")),
                        ), 
                        
                        tags$li(h4("Who will fulfill prescribed medications?"),
                                p("Medication prescriptons are mailed to patients, requiring time for the prescription to be fulfilled and mailed."),
                                selectizeInput("taskFillMailMeds", NULL, jobList, width="50%", selected=jobList[[2]],  multiple = TRUE, options = list(maxItems = 1)))
                        
                      ), # end list
                      
                      h4("Some additional tasks are relevant to the program in addition to those shown in the flow diagram."),
                      
                      tags$ul(
                        tags$li(
                          h5("Will there be regular meetings of the program staff?"), 
                          
                          checkboxInput("checkin", "Check this box if there will be regular meetins of program staff.", TRUE),
                          
                          conditionalPanel(condition = "input.checkin == true",
                                           p("How many hours of meetings per month do you anticipate?"),
                                           numericInput("meetings", NULL, 2, 0, 4, step=0.25, width='50%'), 
                                           
                                           p("And who do you expect to participate?"), 
                                           tags$ul(
                                             tags$li(checkboxInput("counselorMeetings", jobList[[1]], TRUE)),
                                             tags$li(checkboxInput("adminMeetings", jobList[[2]], TRUE)),
                                             tags$li(checkboxInput("mdMeetings", jobList[[3]], FALSE)),
                                             tags$li(checkboxInput("supervisorMeetings", jobList[[4]], TRUE)))
                          )
                        ), 
                        tags$li(h5("Emergency Needs"), 
                                p("Participants may have concerns that arise throughout the program. Who would likely be in charge of handling these concerns?"),
                                selectizeInput("taskEmergencies", NULL, jobList, width="50%", selected=jobList[[4]],  multiple = TRUE, options = list(maxItems = 1)))
                      ),
                  )
                )
              )
      ), 
      
      ### input3 - wages ----
      tabItem("input3", 
              
              # fluidRow(infoBoxOutput("recruitmentCallOut")
              # ),
              
              fluidRow(box(width=12, 
                           h3("What are the expected wages for each role?"), 
                           p(textOutput("recruitText1")),
                           p("We have also estimated how many FTEs per role you might need for the program to serve those individuals."), 
                           p("This page will now ask for your estimates on the salaries for individuals who support the program.")
              )),
              
              fluidRow(
                
                box(title = "Patient Counselors", 
                    width=6, 
                    
                    p("Based on the estimated monthly enrollment numbers and task delegation, we estimate that you will need about:"),
                    tags$ul(
                      tags$li(textOutput("fteCounselor")),
                      # tags$li()
                    ), 
                    p("What is your best estimate of the yearly salary of a tobacco cessation counselor in your setting? Currently, we have this set to the annual wage for 'counselors, social workers, and other' from national wage estimates."), 
                    # numericInput("counselorWage", NULL, blsWageCounselor, width='30%'),
                    autonumericInput("counselorWage", NULL, blsWageCounselor, 
                                     currencySymbolPlacement = "p",
                                     decimalPlaces = 0,
                                     digitGroupSeparator = ",",
                                     decimalCharacter = ".", 
                                     width='30%'),
                    
                    tags$br(), 
                    
                    p("Total counselors that need to be trained:"),
                    p("This is based on expected recruitment numbers and average time counselors spend in tobacco treatment sessions. It's calculated from recruitment numbers already input, so it can't be changed."),
                    numericInput("counselorNumber", NULL, 1, 1, 10, width="30%")
                    # textOutput("fteCounselorTraining")
                    
                ), 
                
                box(title = "Administrative Staff", 
                    width=6, 
                    
                    p("Based on the estimated monthly enrollment numbers and task delegation, we estimate that you will need about:"),
                    tags$ul(
                      tags$li(textOutput("fteAdmin")),
                    ), 
                    p("What is your best estimate of the yearly salary of an administrative support person in your setting? Currently, we have this set to the annual salary for medical assistants from national wage estimates."), 
                    autonumericInput("assistantWage", NULL, blsWageRAtype, width='30%', 
                                     currencySymbolPlacement = "p",
                                     decimalPlaces = 0,
                                     digitGroupSeparator = ",",
                                     decimalCharacter = ".")
                ), 
              ), 
              
              fluidRow(
                
                box(title = "MD", 
                    width=6, 
                    
                    conditionalPanel(
                      condition = "input.reconcileYN=='yes'",
                      p("Based on the estimated monthly enrollment numbers and task delegation, we estimate that you will need about:"),
                      tags$ul(
                        tags$li(textOutput("fteMD")),
                      ), 
                      p("What is your best estimate of the yearly salary of a medical professional who could review and order smoking cessation medications in your setting? Currently, we have this set to the annual salary for a family medicine physician from national wage estimtaes."), 
                      autonumericInput("mdWage", NULL, blsWageMD, width='30%', 
                                       currencySymbolPlacement = "p",
                                       decimalPlaces = 0,
                                       digitGroupSeparator = ",",
                                       decimalCharacter = ".")                        
                    ),
                    conditionalPanel(
                      condition = "input.reconcileYN=='no'", 
                      p("Because no ordering of pending medications / medication reconciliation is needed, no medical professional time is needed for program delivery.")
                    )
                ), 
                
                box(title = "Counselor/Clinic Supervisor", 
                    width=6, 
                    p("Based on the estimated monthly enrollment numbers and task delegation, we estimate that you will need about:"),
                    tags$ul(
                      tags$li(textOutput("fteSupervisor"))
                    ),
                    p("What is your best estimate of the yearly salary of an individual who would supervisor counselors and the Smokefree Support program? Currently, we have this set to the annual wage for 'clinical, counseloring, and school psychologists' from national wage estimates."), 
                    autonumericInput("supervisorWage", NULL, blsWageSupervisor, width='30%', 
                                     currencySymbolPlacement = "p",
                                     decimalPlaces = 0,
                                     digitGroupSeparator = ",",
                                     decimalCharacter = ".") 
                )
              )
              
      ), # end inputs 3
      
      
      
      
      
      
      ### outputs ----
      tabItem(tabName="output1",
              fluidRow(
                box(
                  width=12,
                  h3("Using the values you've provided, we have calculated what you might need to budget over one year to support the Smokefree Support program"),
                  p("Remember! You can always return to earlier pages and change input values to see how that might change what you could expect to pay.")
                )
              ),
              
              #### row 1: call out boxes ----
              fluidRow(infoBoxOutput("x12monthCosts", width=3),
                       infoBoxOutput("recruitmentCallOut2", width=3),
                       infoBoxOutput("costCallout", width=3),
                       infoBoxOutput("calloutTwo", width=3) 
                       
              ), # end fluid row of info boxes
              
              
              #### row 2: graph and additional info ----
              fluidRow(
                
                ##### graph output ----
                box(title = "Output", 
                    width=6,
                    tabBox( 
                      width=12,
                      # tabPanel(title = "regular", 
                      #          plotlyOutput("altPlot")), 
                      tabPanel(title = "Costs Over Time",
                               p("Expected costs per month given estimated recruitment."),
                               plotlyOutput("overTime"), 
                               p("These costs appear 'staggered' because we assume constant, rolling recruitment into the program. Because patients receive 3 months of medication and up to 6 months of counseling, then the maximum monthly costs will be reached after 6 months of implementation."), 
                               p("If recruitment tapers over time, then you can expect lower costs.")
                      ), 
                      tabPanel(title = "Costs Over Time (table)",
                               reactableOutput("tableTest")),
                      # tabPanel(title = "FTE Table", 
                      #          reactableOutput("fteTable")), 
                      
                      # tabPanel(title = "Monthly Over Time", 
                      #          p("Monthly costs over time"),
                      #          plotlyOutput("monthlyCostsPlot")),
                      tabPanel(title = "FTE Over Time (graph)", 
                               p("Expected FTE's per month given estimated recruitment."),
                               plotlyOutput("FTEplotTime"))
                      
                    )), # end tab box
                
                # h3("Use the boxes below to further customize the cost estimates for your health system or clinic."),
                # p("These inputs have been set using numbers from the original Smokefree Support Study cost calculations. As you update information in the below boxes, the values above will auto-update"),
                
                ##### more inputs ----
                box(title="Additional Information and Assumptions", 
                    width=6,
                    tabBox(width=12,
                           
                           tabPanel(title = "Overview", 
                                    h4(textOutput("recruitText")),
                                    p("Patients enrolled in the program receive 3 months of medication, and 6 months of counseling sessions (weekly in month 1, every-other-week in months 2 and 3, and monthly in months 4, 5, and 6 (11 total sessions)."),
                                    p("We assume constant, rolling recruitment into the program. This means that it will take 3-6 months until the maximum costs are reached."),
                                    p("If recruitment tapers over time, then you can expect lower costs.")
                           ),
                           
                           
                           ###### training ----
                           tabPanel(title = "Training",
                                    h4(textOutput("trainMore")),
                                    tags$ol(
                                      tags$li("'Working with Smokers' course, 12 hours, $150 (per counselor)"),
                                      tags$li("TTS course, 32 hours, $1000 (per counselor)", 
                                              tags$ul(
                                                tags$li(checkboxInput("travel", "Is travel required?", TRUE)), 
                                                tags$li(conditionalPanel(condition = "input.travel == true",
                                                                         p("Approximately how many hours will the counselors have to travel for the course (round-trip)? (We assume that counselors are compensated for their travel time and gas costs per hour are $7.)"),
                                                                         numericInput("ttsTravelHours", NULL, 2, 0, 10, step = 0.25, width='25%')))
                                              )),
                                      tags$li("4 hours of motivational interview training (per counselor)") 
                                    ), # end ordered list
                                    p("We assume that existing staff are being trained. There would likely be additional costs associated with hiring new personnel."), 
                                    
                                    p("We also assume that administrative personnel and the counselor supervisor spent 8 hours in initial training.")
                                    
                                    
                           ), # end tab panel training
                           
                           
                           ###### wages ----
                           tabPanel(title = "Wage and Space",
                                    
                                    textOutput("spaceCosts"),
                                    tags$br(), 
                                    tags$ul(
                                      tags$li(p("What is the approximate fringe rate added to hourly wages at your center? 
                                                (If you don't want to take this into account, then this value can be set to 0.)"), 
                                              numericInput("fringe", NULL, value = 0.32, min= 0, max = 1, step=0.1, width='25%')), 
                                      tags$li(p("Based on the task delegation and recruitment estimates, we estimate you will need to budget for about this many FTEs:"), 
                                              numericInput("FTEinput", NULL, value = 1, min = 0, max = 100, step=0.5, width='25%'), 
                                              p("Because this number is calculated ased on prior inputs, it can't be changed directly here.")), 
                                      tags$li(p("How much does office space cost, per FTE and per month, at your center?
                                                (If this isn't relevant to your budgeting and planning, then this value can be set to $0.)"), 
                                              numericInput("spacePerFTE", NULL, min = 0, max = 999999, value = 281.25, width='25%'))
                                    )
                                    
                                    
                           ), # end tab panel wages
                           
                           ###### medication ----
                           tabPanel(title="Medication",
                                    
                                    # h4("Will your clinic be providing smoking cessation medications directly to patients?"), 
                                    # p(strong("Note: program may not work as well if medication is not provided to patients")),
                                    # p("If this box is checked, then we will calculate the expected costs of medications using average numbers of medications prescribed and the costs of medications shown below."), 
                                    # checkboxInput("medsrequired", "Medications will be provided.", TRUE),
                                    
                                    # h4("Is reconciliation of smoking cessation medication required?"),
                                    # p("If this box is checked, then we will account for a psychiatrists time to reconcile prescriptions (less than 5 minutes per patient per 28-day prescription)."),
                                    # checkboxInput("reconciliation", "Reconciliation required.", TRUE),
                                    
                                    p("What is the cost, in dollars, to mail medication to patients?"),
                                    numericInput("shippingCost", NULL, 27.50, 0, 1000, step=1, width='10%'),
                                    
                                    
                                    h4("You can also change the costs per 28 day supply of the medications we are using below."),
                                    tags$ul(
                                      tags$li("Varenicline (starter pack): ", numericInput("varenStarter", NULL, 282.37, 0, 500, step=10, width='20%')), 
                                      tags$li("Varenicline (continuing): ", numericInput("varenContinuing", NULL, 385.20, 0, 600, step=10, width='20%')), 
                                      tags$li("Bupropion: ", numericInput("bupropion", NULL, 229.12, 0, 500, step=10, width='20%')), 
                                      tags$li("Nicotine Replacement Patch: ", numericInput("nrtPatch", NULL, 51.96, 0, 100, step=5, width='20%')), 
                                      tags$li("Nicotine Replacement Lozenge: ", numericInput("nrtLozenge", NULL, 22.19, 0, 100, step=5, width='20%'))
                                    ),
                                    
                                    # TODO - perhaps add average numbers of meds distributed here. 
                                    
                           ), # end tab panel medication
                           
                           tabPanel(title = "Office Supplies",
                                    textOutput("paperCosts"), 
                                    tags$br(), 
                                    textOutput("sessionShells")
                                    
                                    
                           ) # end tab panel patients
                           
                           
                           # tabPanel(title="Office Supplies",
                           #          p("Default values are provided from the study"),
                           #          numericInput("paper", "Price per Sheet of Paper", 0.0096),
                           #          numericInput("colorprint", "Color Printing (dollars per printed page)", 0.14),
                           #          numericInput("bwprint", "Black and White Printing (dollars per printed page)", 0.0016),
                           #          numericInput("envelopes", "Price per envelope", 0.03198),
                           #          numericInput("priceperitemmailed", "Price per item mailed", 0.46)
                           
                           # ) # end tab panel office supplies
                           
                    ) # end tab box
                ) # end box
              ) # end fluid row for output
              
              # fluidRow(downloadButton("downloadInputs", "Download Inputs"))   
              
      ) # endtab item 'outputStep2'
    ) # end tab itemS
  ) # end dashboard body
) # end dashboard page





# server ----  
server <- function(input, output, session) {
  
  ## Declare inputs from the UI as reactive ----
  
  # base initial counselor number on the initial FTEs calculated via recruitment numbers
  observeEvent(FTEs(), 
               {updateNumericInput(session, 
                                   inputId = "counselorNumber", 
                                   value = ceiling(FTEs() %>% filter(who=="Patient Counselor" & month==12) %>% pull(FTE)), 
                                   min = ceiling(FTEs() %>% filter(who=="Patient Counselor" & month==12) %>% pull(FTE)), 
                                   max = ceiling(FTEs() %>% filter(who=="Patient Counselor" & month==12) %>% pull(FTE)))
                 updateNumericInput(session,
                                    inputId = "FTEinput",
                                    value = round(FTEs() %>% filter(month==12) %>% select(FTE) %>% sum(), digits=2),
                                    min = round(FTEs() %>% filter(month==12) %>% select(FTE) %>% sum(), digits=2),
                                    max = round(FTEs() %>% filter(month==12) %>% select(FTE) %>% sum(), digits=2))}
  )
  
  
  counselors <- reactive({ as.numeric(input$counselorNumber) })
  
  
  
  ttsTravelRequired <- reactive({ input$travel })
  ttsTravelHours <- reactive({input$ttsTravelHours})
  
  checkin <- reactive({input$checkin})
  checkinRecurrence <- reactive({input$meetings})
  
  
  hourlySalaryOfCounselor <- reactive({ (input$counselorWage/2080)*(1 + input$fringe) })
  hourlySalaryOfPD <- reactive({ (input$projectDirectorWage/2080)*(1+input$fringe) })
  hourlySalaryOfAssistant <- reactive({ (input$assistantWage/2080)*(1+input$fringe) })
  hourlySalaryOfSupervisor <- reactive({(input$supervisorWage/2080)*(1+input$fringe)})
  
  hourlySalaryOfMD <- reactive({(input$mdWage/2080)*(1+input$fringe)})
  
  taskMailSmokers <- reactive({input$taskMailSmokers})
  taskCallSmokers <- reactive({input$taskCallSmokers})
  taskIntroClinic <- reactive({input$taskIntroClinic})
  taskCounseling <- reactive({input$taskCounseling})
  reconcileYN <- reactive({input$reconcileYN})
  taskFillMailMeds <- reactive({input$taskFillMailMeds})
  taskEmergencies <- reactive({input$taskEmergencies})
  
  
  FTE <- reactive({input$FTEinput})
  spaceCostPerFTEperMonth <- reactive({input$spacePerFTE})
  
  
  # patient flows
  clinicPatients <- reactive({input$clinicPatients})
  smokerPatients <- reactive({clinicPatients()*(input$smokerPatients/100)})
  eligiblePatients <- reactive({smokerPatients()*(input$eligiblePatients/100)})
  patientsDoTelehealthVisit <- reactive({eligiblePatients()*(input$patientsTelehealth/100)})
  patientsRecruited <- reactive({patientsDoTelehealthVisit()*(input$patientsRecruited/100)})
  
  # patients retention in sessions, based on recruitment numbers
  expectedPatientsBySession <- reactive({proportionReturningBySessionMGH %>%
      mutate(expectedPatients = patientsRecruited()*expectedProportionReturning)})
  
  
  reconciliationRequired <- reactive({input$reconciliation})
  
  
  medCosts <- reactive({tribble(~med, ~x28dayPrice, ~fillHours, ~shipping, 
                                "varenStarter", input$varenStarter, 1, input$shippingCost, 
                                "varenContinuing", input$varenContinuing, 1, input$shippingCost,
                                "bupropion", input$bupropion, 1, input$shippingCost,
                                "nrtPatch", input$nrtPatch, 0.5, input$shippingCost,
                                "nrtLozenge", input$nrtLozenge, 0.5, input$shippingCost)})
  
  
  
  
  ## Hard code the non-reactive pieces we need ----
  
  nonReactiveConstant <- tribble(~thing, ~value,
                                 "workingWithSmokersCourse_FeePerCounselor", 150,
                                 "workingWithSmokersCourse_HoursPerCounselor", 12,
                                 
                                 "ttsCourse_FeePerCounselor", 1000,
                                 "ttsCourse_HoursPerCounselor", 32,
                                 
                                 "miSession_HoursPerCounselor", 4,
                                 
                                 "gasCostPerHour", 7,
                                 
                                 "supervisorHoursTrainAssistant", 8,
                                 "projectDirectorHoursTrainAssistant", 40,
                                 
                                 "folder", 2.49,
                                 "stickerEligible", 0.26365,
                                 "stickerConsented", 0.4347,
                                 "paper", 0.0096,
                                 "colorPrint", 0.14,
                                 "bwPrint", 0.0016,
                                 "envelope", 0.03198,
                                 "priceToMail", 0.46,
                                 "infoFolderPages", 24, 
                                 
                                 "ehrIntroduction", 0.132, # ASSUMPTION - messaging via EHR takes the SAME AMOUNT OF TIME AS 'TIME FULL CHART SCREEN' from original cost work
                                 # "timePreScreenClinic", 0.02,
                                 # "timeFullChartScreen", 0.132,
                                 "timeCallPatients", 0.0784,
                                 "callsPerPatient", 4.1,
                                 # "pctEligiblePtsApproached", 0.5,
                                 # "numberOfApproachesPerPatient", 1.2,
                                 "timeIntroClinicVisit", 0.5,
                                 
                                 # initial number is across IT and ST, so it is actually the number of emergencies for 176 or 109 people, not the 'recruited' people. 
                                 # adjust here to be 'emergencies per recruited patient' so that when it is scaled to # of people recruited it is appropriate.
                                 # ALSO, this is across the entirety of the program, so adjust to be 
                                 # issues/patient/month
                                 # 52 months found in '2. MGH Medication' sheet, cell D33
                                 
                                 "supervisorIssues", 19/176/52, # issue/patient/month
                                 "supervisorHrsPerIssue", 0.5, # hours/issue
                                 "counselorIssues", 24/176/52, # issue/patient/month
                                 "counselorHrsPerIssue", 0.166, # hours/issue
                                 
                                 "counselorCallsPerSession", 2.2, 
                                 "counselorHoursPerSessionCall", 0.03,
                                 
                                 # "shippingCost", 27.35, # dollars per med shipped
                                 # "vareniclineBuproprionFillHours", 1, # hours per med fill
                                 # "nrtFillHours", 0.5,# hours per med fill
                                 "raPrepReconciliation", 0.25/87, # hours per month per patient, to prep for reconciliation, given that there were 87 patient
                                 "mdReconcile", 0.05) # hours per patient
  
  
  
  
  nonReactiveConstantList <- as.list(nonReactiveConstant$value)
  names(nonReactiveConstantList) <- nonReactiveConstant$thing
  
  sessionShells <- tribble(~session, ~printedPages,
                           1, 7,
                           2, 14,
                           3, 14,
                           4, 15,
                           5, 7,
                           6, 8,
                           7, 7,
                           8, 7,
                           9, 7,
                           10, 8,
                           11, 6)
  
  
  
  
  
  
  
  
  ## Do reactive calculations ----
  
  
  ### Training ----
  #### Working with smokers course ----
  # no calcs done - is a fee per counselor, and a set number of hours per counselor
  # it's online, so no travel required
  
  
  #### TTS specific course ----
  ttsCourse_HoursPerCounselor <- reactive({nonReactiveConstantList$ttsCourse_HoursPerCounselor + (ttsTravelHours()*ttsTravelRequired())})
  ttsCourse_Gas <- reactive({ttsTravelHours()*nonReactiveConstantList$gasCostPerHour*ttsTravelRequired()})  
  
  #### Motivational interview training ----
  miInterviewTrainerCost <- reactive({nonReactiveConstantList$miSession_HoursPerCounselor*(as.numeric(blsWageTrainer)*(1+input$fringe))})
  
  
  #### Training admin/staff/assistant ----
  # supervisorTrainTime <- reactive({nonReactiveConstantList$supervisorHoursTrainAssistant})
  # projectDTrainTime <- reactive({nonReactiveConstantList$projectDirectorHoursTrainAssistant})
  # assistantTrainTime <- reactive({nonReactiveConstantList$projectDirectorHoursTrainAssistant})
  
  
  #### Totals ----
  training_CourseFees <- reactive({nonReactiveConstantList$workingWithSmokersCourse_FeePerCounselor + nonReactiveConstantList$ttsCourse_FeePerCounselor + ttsCourse_Gas()})
  training_CourseFees_total <- reactive({training_CourseFees() * counselors()})
  
  training_CounselorTime <- reactive({nonReactiveConstantList$workingWithSmokersCourse_HoursPerCounselor + ttsCourse_HoursPerCounselor() + nonReactiveConstantList$miSession_HoursPerCounselor})
  training_CounselorTime_total <- reactive({training_CounselorTime() * counselors()})
  
  approxTrainOneCounselor <- reactive({training_CourseFees() + miInterviewTrainerCost() + training_CounselorTime()*hourlySalaryOfCounselor()})
  
  
  
  ### Supervision ----
  
  # hours per month
  checkIns_HoursPerCounselor <- reactive({checkin()*checkinRecurrence()*input$counselorMeetings*counselors()})
  checkIns_HoursPerAssistant <- reactive({checkin()*checkinRecurrence()*input$adminMeetings})
  checkIns_HoursPerCounselorSupervisor <- reactive({checkin()*checkinRecurrence()*input$supervisorMeetings})
  
  
  
  
  
  
  
  ### Enrollment ----
  
  #### EHR messages ----
  # hours per month
  ehrMessagesToPotentiallyEligiblePatients <- reactive({eligiblePatients()*nonReactiveConstantList$ehrIntroduction})
  
  
  #### Calls ----
  # hours per month
  callsToPotentiallyEligiblePatients <- reactive({(eligiblePatients()*nonReactiveConstantList$callsPerPatient*nonReactiveConstantList$timeCallPatients)})
  
  
  #### Initial telehealth visits ----
  # hours per month
  initialTobaccoVisits <- reactive({nonReactiveConstantList$timeIntroClinicVisit*patientsDoTelehealthVisit()})
  
  
  
  ### Equipment ----
  
  #### Info Folders ----
  infoFolderCost <- (nonReactiveConstantList$infoFolderPages*nonReactiveConstantList$colorPrint) + # cost to print the pages
    (round(nonReactiveConstantList$infoFolderPages/2, 0)*nonReactiveConstantList$paper) +  # paper cost
    (nonReactiveConstantList$folder) # folder itself
  
  infoFolders <- reactive({infoFolderCost*patientsRecruited()}) 
  
  
  
  #### "Session Shells" for counselors ----
  sessionShellCost <- reactive({sessionShells %>%
      left_join(expectedPatientsBySession(), by="session") %>%
      
      mutate(paperNeeded = round(printedPages/2, digits=0), # double sided printing
             costPerSessionPerPatient = printedPages*nonReactiveConstantList$bwPrint + paperNeeded*nonReactiveConstantList$paper,
             costPerSession = costPerSessionPerPatient*expectedPatients)})
  
  sessionShellCosts_Month1 <- reactive({sum(filter(sessionShellCost(), session %in% c(1,2,3,4))$costPerSession)})
  
  sessionShellCosts_Month2 <- reactive({sum(filter(sessionShellCost(), session %in% c(1,2,3,4,5,6))$costPerSession)})
  sessionShellCosts_Month3 <- reactive({sum(filter(sessionShellCost(), session %in% c(1,2,3,4,5,6,7,8))$costPerSession)})
  
  sessionShellCosts_Month4 <- reactive({sum(filter(sessionShellCost(), session %in% c(1,2,3,4,5,6,7,8, 9))$costPerSession)})
  sessionShellCosts_Month5 <- reactive({sum(filter(sessionShellCost(), session %in% c(1,2,3,4,5,6,7,8, 9, 10))$costPerSession)})
  sessionShellCosts_Month6 <- reactive({sum(filter(sessionShellCost(), session %in% c(1,2,3,4,5,6,7,8, 9, 10, 11))$costPerSession)})
  
  
  
  #### Physical space for program team ----
  spaceCostPerMonth <- reactive({FTE()*spaceCostPerFTEperMonth()})
  
  
  
  
  
  
  
  
  ### Session delivery ----
  
  # calling patients for telephone sessions
  # there are 11 sessions per patient recruited
  # for each of those sessions, a counselor makes an average number of calls (counselorCallsPerSession)
  # those total calls each have an average hour per session call (e.g., it takes a bit of time to actually sit there and dial the phone)
  # patientCalls <- reactive({ (patientsRecruited() * 11 * nonReactiveConstantList$counselorCallsPerSession)*nonReactiveConstantList$counselorHoursPerSessionCall})
  
  
  # time in sessions
  # hours per month
  sessionTime2 <- reactive({sessionTimesMGH %>%
      
      left_join(expectedPatientsBySession(), by="session") %>%
      
      # expected patients returning for said session is based on patients Recruited above
      mutate(sessionCallHours = patientsRecruited()*nonReactiveConstantList$counselorCallsPerSession*nonReactiveConstantList$counselorHoursPerSessionCall, 
             sessionDeliveryHours = hrsPerSessionPerPatient*expectedPatients,
             totalSessionHours = sessionCallHours + sessionDeliveryHours
      )})
  
  # 4 weekly telephone sessions = 1 month
  # two bi-weekly telephone sessions over 2 months = months 2 and 3
  # 3 booster sessions delivered monthly
  # with new patients entering each month, this means that it will take 6 months until there is a full 'cohort' of patients incurring costs. 
  # ADD MORE EXPLANATION HERE
  
  sessionTime_Month1 <- reactive({sum(filter(sessionTime2(), session %in% c(1,2,3,4))$totalSessionHours)})
  
  sessionTime_Month2 <- reactive({sum(filter(sessionTime2(), session %in% c(1,2,3,4,5,6))$totalSessionHours)})
  sessionTime_Month3 <- reactive({sum(filter(sessionTime2(), session %in% c(1,2,3,4,5,6,7,8))$totalSessionHours)})
  
  sessionTime_Month4 <- reactive({sum(filter(sessionTime2(), session %in% c(1,2,3,4,5,6,7,8,9))$totalSessionHours)})
  sessionTime_Month5 <- reactive({sum(filter(sessionTime2(), session %in% c(1,2,3,4,5,6,7,8,9,10))$totalSessionHours)})
  sessionTime_Month6 <- reactive({sum(filter(sessionTime2(), session %in% c(1,2,3,4,5,6,7,8,9,10,11))$totalSessionHours)})
  
  
  
  # emergency needs
  # assume that the number of 'issues' observed in the real world is the total number of supervisor and counselor issues from the excel sheet
  # the 'supervisorIssues' and 'counselorIssues' are in issues/person
  # and then supervisorHrsPerIssue is hours/issue
  # hours/person * people = hours for input into the larger data table. 
  emergencies <- reactive({
    ((nonReactiveConstantList$supervisorIssues + nonReactiveConstantList$counselorIssues)*nonReactiveConstantList$supervisorHrsPerIssue)*patientsRecruited()
  })
  
  
  
  
  ### Medication ----
  # again all based on patients recruited
  
  #### Costs of medication ----
  # Based on the expected 'numbers per patient' which are calculated externally and filtered based on site
  # These are 'average' values that are like, each patient got 0.2 varenicline, 1.5 nrt lozenges, etc. 
  medCostsByMed <- reactive({medCosts() %>%
      left_join(expectedMedNumbersPerPatientMGH, by="med") %>%
      mutate(expectedMedNumbers = avgMedPerPatient*patientsRecruited(),
             indivMeds = x28dayPrice*expectedMedNumbers, 
             indivMedShipping = shipping*expectedMedNumbers, 
             timeToFill = fillHours*expectedMedNumbers)})
  
  medCostsTotal <- reactive({medCostsByMed() %>% select(indivMeds) %>% sum()})
  medShippingTotal <- reactive({medCostsByMed() %>% select(indivMedShipping) %>% sum()})
  medFillingTotal <- reactive({medCostsByMed() %>% select(timeToFill) %>% sum()})
  
  medCosts_Month1 <- reactive({medCostsTotal()*(1/3)})
  medCosts_Month2 <- reactive({medCostsTotal()*(2/3)})
  medCosts_Month3 <- reactive({medCostsTotal()*(3/3)})
  
  medShipping_Month1 <- reactive({medShippingTotal()*(1/3)})
  medShipping_Month2 <- reactive({medShippingTotal()*(2/3)})
  medShipping_Month3 <- reactive({medShippingTotal()*(3/3)})
  
  medFilling_Month1 <- reactive({medFillingTotal()*(1/3)})
  medFilling_Month2 <- reactive({medFillingTotal()*(2/3)})
  medFilling_Month3 <- reactive({medFillingTotal()*(3/3)})
  
  
  # TODO - should mailing/delivery time be inclued here? See listwise costs spreadsheet row 162
  
  #### Reconciliation/med order ----
  # assume 3 minutes of reconciliation per patient recruited per month
  # by the MD/oncologist
  
  # first wave of recruits for first month of meds; 
  # second wave of recruits for first month; first wave for second month;
  # third wave, first month of meds; second wave second month; first wave, third month; 
  # and then is maintained at 3x for the rest of the time
  # same logic for the prepping of the list for reconciliation
  medReconcilitation_Month1 <- reactive({
    if (input$reconcileYN == "yes") {
      nonReactiveConstantList$mdReconcile*patientsRecruited()*1
    } else {
      0
    } 
  })
  
  medReconcilitation_Month2 <- reactive({
    if (input$reconcileYN == "yes") {
      nonReactiveConstantList$mdReconcile*patientsRecruited()*2
    } else {
      0
    } 
  })
  
  
  medReconcilitation_Month3 <- reactive({
    if (input$reconcileYN == "yes") {
      nonReactiveConstantList$mdReconcile*patientsRecruited()*3
    } else {
      0
    } 
  })
  
  
  prepReconciliation_Month1 <- reactive({
    if (input$reconcileYN == 'yes'){
      nonReactiveConstantList$raPrepReconciliation*patientsRecruited()*1
    } else {
      0
    }
  })
  
  prepReconciliation_Month2 <- reactive({
    if (input$reconcileYN == 'yes'){
      nonReactiveConstantList$raPrepReconciliation*patientsRecruited()*2
    } else {
      0
    }
  })
  
  prepReconciliation_Month3 <- reactive({
    if (input$reconcileYN == 'yes'){
      nonReactiveConstantList$raPrepReconciliation*patientsRecruited()*3
    } else {
      0
    }
  })
  
  
  
  
  
  ## Combine output into one big dataset ----
  
  monthlyCosts <- reactive({tribble(~Category, ~label, ~month, ~units, ~who, ~value,
                                    "Training", "Counselor training time", 0, "hours", "Patient Counselor", training_CounselorTime_total(), 
                                    "Training", "Course fees", 0, "dollars", NA_character_, training_CourseFees_total(), 
                                    "Training", "MI Interview trainer", 0, "dollars", NA_character_, miInterviewTrainerCost(), 
                                    "Training", "Admin/Asst Training", 0, "hours", "Administrative Staff", nonReactiveConstantList$supervisorHoursTrainAssistant, 
                                    "Training", "Supervisor Training of Admin/Asst", 0, "hours", "Counselor Supervisor", nonReactiveConstantList$supervisorHoursTrainAssistant,
                                    
                                    "Team check-ins", "Counselors attending check-ins", c(seq(1,12,1)), "hours", "Patient Counselor", checkIns_HoursPerCounselor(),  
                                    "Team check-ins", "Admins/Assts attending check-ins", c(seq(1,12,1)), "hours", "Administrative Staff", checkIns_HoursPerAssistant(), 
                                    "Team check-ins", "Supervisor attending check-ins", c(seq(1,12,1)), "hours", "Counselor Supervisor", checkIns_HoursPerCounselorSupervisor(),  
                                    
                                    "Enrollment", "EHR messages to eligible smokers", c(seq(1,12,1)), "hours", taskMailSmokers(), ehrMessagesToPotentiallyEligiblePatients(), 
                                    "Enrollment", "Calls to eligible smokers", c(seq(1,12,1)), "hours", taskCallSmokers(), callsToPotentiallyEligiblePatients(), 
                                    "Enrollment", "Initial Telehealth Tobacco Visits", c(seq(1, 12, 1)), "hours", taskIntroClinic(), initialTobaccoVisits(),
                                    
                                    "Session Delivery", "Counseling sessions", 1, "hours", taskCounseling(), sessionTime_Month1(),
                                    "Session Delivery", "Counseling sessions", 2, "hours", taskCounseling(), sessionTime_Month2(),
                                    "Session Delivery", "Counseling sessions", 3, "hours", taskCounseling(), sessionTime_Month3(),
                                    "Session Delivery", "Counseling sessions", 4, "hours", taskCounseling(), sessionTime_Month4(),
                                    "Session Delivery", "Counseling sessions", 5, "hours", taskCounseling(), sessionTime_Month5(),
                                    "Session Delivery", "Counseling sessions", 6, "hours", taskCounseling(), sessionTime_Month6(), 
                                    "Session Delivery", "Counseling sessions", 7, "hours", taskCounseling(), sessionTime_Month6(), 
                                    "Session Delivery", "Counseling sessions", 8, "hours", taskCounseling(), sessionTime_Month6(), 
                                    "Session Delivery", "Counseling sessions", 9, "hours", taskCounseling(), sessionTime_Month6(), 
                                    "Session Delivery", "Counseling sessions", 10, "hours", taskCounseling(), sessionTime_Month6(), 
                                    "Session Delivery", "Counseling sessions", 11, "hours", taskCounseling(), sessionTime_Month6(), 
                                    "Session Delivery", "Counseling sessions", 12, "hours", taskCounseling(), sessionTime_Month6(), 
                                    "Session Delivery", paste0("Info folders for new participants (", scales::dollar(infoFolderCost, largest_with_cents = 1), " per person)"), c(seq(1,12,1)), "dollars", NA_character_, infoFolders(), 
                                    "Session Delivery", "Counselor paper guides for sessions", 1, "dollars", NA_character_, sessionShellCosts_Month1(),
                                    "Session Delivery", "Counselor paper guides for sessions", 2, "dollars", NA_character_, sessionShellCosts_Month2(),
                                    "Session Delivery", "Counselor paper guides for sessions", 3, "dollars", NA_character_, sessionShellCosts_Month3(),
                                    "Session Delivery", "Counselor paper guides for sessions", 4, "dollars", NA_character_, sessionShellCosts_Month4(),
                                    "Session Delivery", "Counselor paper guides for sessions", 5, "dollars", NA_character_, sessionShellCosts_Month5(),
                                    "Session Delivery", "Counselor paper guides for sessions", c(seq(6,12,1)), "dollars", NA_character_, sessionShellCosts_Month6(),
                                    "Session Delivery", "Emergencies", c(seq(1,12,1)), "hours", taskEmergencies(), emergencies(),
                                    
                                    "Medication", "Actual medication costs", 1, "dollars", NA_character_, medCosts_Month1(), 
                                    "Medication", "Actual medication costs", 2, "dollars", NA_character_, medCosts_Month2(), 
                                    "Medication", "Actual medication costs", c(seq(3,12,1)), "dollars", NA_character_, medCosts_Month3(),
                                    
                                    "Medication", "Medication shipping", 1, "dollars", NA_character_, medShipping_Month1(), 
                                    "Medication", "Medication shipping", 2, "dollars", NA_character_, medShipping_Month2(), 
                                    "Medication", "Medication shipping", c(seq(3,12,1)), "dollars", NA_character_, medShipping_Month3(),
                                    
                                    "Medication", "Time to fill and ship", 1, "hours", taskFillMailMeds(), medFilling_Month1(),
                                    "Medication", "Time to fill and ship", 2, "hours", taskFillMailMeds(), medFilling_Month2(),
                                    "Medication", "Time to fill and ship", c(seq(3,12,1)), "hours", taskFillMailMeds(), medFilling_Month3(), 
                                    
                                    "Medication", "Asst/admin prepare for MD", 1, "hours", "Administrative Staff", prepReconciliation_Month1(), 
                                    "Medication", "Asst/admin prepare for MD", 2, "hours", "Administrative Staff", prepReconciliation_Month2(), 
                                    "Medication", "Asst/admin prepare for MD", c(seq(3,12,1)), "hours", "Administrative Staff", prepReconciliation_Month3(),
                                    
                                    "Medication", "MD ordering/reconciling", 1, "hours", "MD", medReconcilitation_Month1(), 
                                    "Medication", "MD ordering/reconciling", 2, "hours", "MD", medReconcilitation_Month2(), 
                                    "Medication", "MD ordering/reconciling", c(seq(3,12,1)), "hours", "MD", medReconcilitation_Month3(), 
                                    
                                    "Space", "Space cost based on total FTEs", c(seq(1,12,1)), "dollars", NA_character_, spaceCostPerMonth()
                                    
  ) %>%
      
      unnest(month) %>%
      
      mutate(wage = case_when(who=="Patient Counselor" ~ hourlySalaryOfCounselor(), 
                              who=="Administrative Staff" ~ hourlySalaryOfAssistant(), 
                              who=="MD" ~ hourlySalaryOfMD(), 
                              who=="Counselor Supervisor" ~ hourlySalaryOfSupervisor(), 
                              TRUE ~ 0), 
             cost = if_else(units=="hours", 
                            value*wage, 
                            value), 
             costF = scales::dollar(cost, largest_with_cents=1), 
             label1 = paste0(costF, ": ", label))
  })
  
  
  notSoBigData2 <- reactive({monthlyCosts() %>%
      group_by(Category, month) %>%
      summarise(totalCosts = sum(cost), 
                label2 = str_c(label1, collapse = "\n"),
                .groups="drop") %>%
      mutate(costF = scales::dollar(totalCosts, largest_with_cents=1), 
             label3 = paste0("Total ", Category, ": ", costF, 
                             "\n", label2))})
  
  monthlyTotals <- reactive({monthlyCosts() %>%
      group_by(month) %>%
      summarise(totalCostsMonthly = sum(cost), 
                .groups = "drop") %>%
      mutate(totalCostsMonthlyF = scales::dollar(totalCostsMonthly, largest_with_cents=1))
  })
  
  totalCosts <- reactive({monthlyCosts() %>%
      summarise(totalCosts = sum(cost)) %>%
      mutate(costF = scales::dollar(totalCosts, largest_with_cents=1))
  })
  
  
  FTEs <- reactive({monthlyCosts() %>%
      filter(units=="hours") %>%
      group_by(who, month) %>%
      summarise(totalMonthlyHours = sum(value),
                from = str_c(label, collapse = "\n"),
                .groups = "drop") %>%
      mutate(hoursPerWeek = totalMonthlyHours/4,
             FTE = hoursPerWeek/40)})
  
  
  
  altFTE <- reactive({
    monthlyCosts() %>%
      filter(units=='hours') %>%
      mutate(hoursPerWeek = value/4, 
             FTE = hoursPerWeek/40, 
             label1 = paste0(label, " (", round(FTE, digits=2), ")")) %>%
      group_by(who, month) %>%
      summarise(totalFTE = sum(FTE),
                label2 = str_c(label1, collapse = "\n"),
                .groups="drop") %>%
      mutate(label3 = paste0(who, " total FTE (", round(totalFTE, digits=2), ")", 
                             "\n", label2))
    
  })
  
  ## Create output for UI ----
  ### Info Boxes ----
  #### Cost call out ----
  output$costCallout <- renderInfoBox({
    infoBox(
      value = scales::dollar(sum((monthlyCosts() %>% filter(Category=="Training"))$cost), largest_with_cents=1),
      title = paste0("One-time training costs"),
      icon = icon("dollar-sign"),
      color = "olive"
    )
  })
  
  #### Number needed to treat ----      
  numberNeededToTreat <- round(100/(34.5-14.3), digits=0)
  
  output$calloutTwo <- renderInfoBox({
    infoBox(title = "Number Needed To Treat (program vs. Usual Care)", 
            value = paste0(numberNeededToTreat, " participants treated per 1 additional quit"), 
            # title = paste0("Monthly costs to recruit and enroll ", patientsRecruited(), " patients"),
            # value = scales::dollar(sum((bigData() %>% filter(recurrence=="monthly" & category=="Enrollment"))$cost), largest_with_cents=1),
            icon = icon("chart-bar"),
            color = "light-blue")
  })
  
  #### Recruitment ----
  output$recruitmentCallOut <- renderInfoBox({
    infoBox(title = "Expected Patients Recruited", 
            value = paste0(round(patientsRecruited(), 
                                 digits=0), " per month"), 
            icon = icon("chart-bar"),
            color = "fuchsia")
  })
  
  output$recruitmentCallOut2 <- renderInfoBox({
    infoBox(title = "Expected Patients Recruited", 
            value = paste0(round(patientsRecruited(), 
                                 digits=0), " per month"), 
            icon = icon("chart-bar"),
            color = "fuchsia")
  })
  
  
  
  output$x12monthCosts <- renderInfoBox({
    infoBox(title = "Total costs over 12 months", 
            value = totalCosts() %>% pull(costF), 
            icon = icon("dollar-sign"),
            color = "teal")
  })
  
  
  
  
  ### Text output ----
  output$recruitText <- renderText(paste0("Your clinic could expect to enroll ", 
                                                                 round(patientsRecruited(), 
                                                                       digits=0), 
                                                                 " patients each month."))
  
  output$recruitText1 <- output$recruitText <- renderText(paste0("Based on the recruitment numbers you've input, your setting could expect to enroll about ", 
                                                                 round(patientsRecruited(), 
                                                                       digits=0), 
                                                                 " patients each month."))
  
  
  output$trainMore <- renderText(paste0("The approximate time to train one new counselor is ", 
                                        training_CounselorTime(), 
                                        " hours."))
  
  
  output$paperCosts <- renderText(paste0("New participants in the program are given information folders that include printed information about quitting, medication fact sheets, and a medication log, which are expected to cost approximately ",
                                         scales::dollar(infoFolderCost, largest_with_cents = 1), " per person, for a total of ", 
                                         monthlyCosts() %>% filter(str_detect(label, "Info folders for new participants") & month==1) %>% pull(costF), 
                                         " per month, based on your expected recruitment numbers."))
  
  output$sessionShells <- renderText(paste0("If counselors use paper shells provided by the original program developers, the paper for these will cost at most ", 
                                            scales::dollar(sessionShellCosts_Month6(), largest_with_cents = 1), " per month."))
  
  
  
  output$spaceCosts <- renderText(paste0("We expect space for program providers to cost about: ", 
                                         scales::dollar(spaceCostPerMonth(), largest_with_cents = 1), 
                                         " based on ", 
                                         FTE(), " FTEs per month and monthly space costs of ", 
                                         scales::dollar(spaceCostPerFTEperMonth(), largest_with_cents = 1), " per FTE")
  )
  
  output$fteCounselor <- renderText(paste0(round(FTEs() %>% filter(who=="Patient Counselor" & month==12) %>% pull(FTE), digits=2), 
                                           " counselor FTEs maximum."))
  
  
  
  output$fteAdmin <- renderText(paste0(round(FTEs() %>% filter(who=="Administrative Staff" & month==12) %>% pull(FTE), digits=2), 
                                       " administrative FTEs maximum."))
  
  
  output$fteMD <- renderText(paste0(round(FTEs() %>% filter(who=="MD" & month==12) %>% pull(FTE), digits=2), 
                                    " MD FTEs maximum."))
  
  output$fteSupervisor <- renderText(paste0(round(FTEs() %>% filter(who=="Counselor Supervisor" & month==12) %>% pull(FTE), digits=2), 
                                            " FTEs maximum."))
  
  
  
  # output$PRINTING <- renderText(paste0(notSoBigData2()))
  
  
  
  ### Plot over time (current) ----
  
  output$overTime <- renderPlotly({
    pp<- ggplot(data=notSoBigData2(), 
                aes(x=month, 
                    y=totalCosts, 
                    fill=fct_reorder(Category, totalCosts), 
                    text=label3)) + 
      geom_bar(stat="identity", position="stack") + 
      
      # these colors were selected manually by looking at show_col(pal_d3("category10")(10))
      # and picking which colors I wanted to go with each
      # can easily be changed
      scale_fill_manual(values = pal_d3("category10")(10)[c(1,2,3,4,8,5)]) +
      scale_y_continuous(labels = scales::label_dollar()) + 
      scale_x_continuous(breaks = c(seq(0, 12, 1))) + 
      theme(strip.background=element_rect(fill="lightgray", 
                                          color="black", 
                                          linetype="solid"), 
            strip.text = element_text(face="bold", size=12), 
            # axis.title.x = element_blank(), 
            axis.title.y = element_blank(),
            axis.text.y = element_text(size=10), 
            axis.text.x = element_text(size=10),
            legend.position = "bottom"
      ) +
      labs(fill = "Category of Cost")
    
    
    ggplotly(pp, tooltip=c("text"))
    
  })
  
  
  ### Monthly costs plot ----
  output$monthlyCostsPlot <- renderPlotly({
    pp<- ggplot(data=monthlyTotals(), 
                aes(x=month, 
                    y=totalCostsMonthly, 
                    text=totalCostsMonthlyF)) + 
      geom_bar(stat="identity", fill="lightgray", colour="black") + 
      theme_bw() + 
      geom_text(aes(label=totalCostsMonthlyF), angle=45) + 
      
      scale_y_continuous(labels = scales::label_dollar()) + 
      scale_x_continuous(breaks = c(seq(0, 12, 1))) + 
      theme(strip.background=element_rect(fill="lightgray", 
                                          color="black", 
                                          linetype="solid"), 
            strip.text = element_text(face="bold", size=12), 
            # axis.title.x = element_blank(), 
            axis.title.y = element_blank(),
            axis.text.y = element_text(size=10), 
            axis.text.x = element_text(size=10),
            legend.position = "bottom"
      ) 
  })
  
  ### FTE over time ----
  output$FTEplotTime <- renderPlotly({
    p2 <- ggplot(data = altFTE(), 
                 aes(x=month, 
                     y=totalFTE, 
                     fill=fct_reorder(who, totalFTE), 
                     text = label3)) + 
      geom_bar(stat="identity", position="stack") + 
      scale_fill_simpsons() + 
      theme_bw() + 
      scale_x_continuous(breaks = c(seq(0, 12, 1))) + 
      theme(strip.background=element_rect(fill="lightgray", 
                                          color="black", 
                                          linetype="solid"), 
            strip.text = element_text(face="bold", size=12), 
            # axis.title.x = element_blank(), 
            axis.title.y = element_blank(),
            axis.text.y = element_text(size=10), 
            axis.text.x = element_text(size=10)
      ) +
      labs(fill = "Personnel")
    
    
    ggplotly(p2, tooltip = 'text')
    
    
  })
  
  
  
  ### Tables ----
  output$tableTest <- renderReactable({reactable(notSoBigData2() %>% select(Month=month, Category, Total = totalCosts, Breakdown=label2),
                                                 groupBy = "Month", 
                                                 columns = list(Total = colDef(minWidth=75,
                                                                               aggregate = "sum", format=colFormat(prefix = "$", separators = TRUE, digits = 0)), 
                                                                Month = colDef(minWidth = 50), 
                                                                Category = colDef(minWidth=100),
                                                                Breakdown = colDef(minWidth = 250)), 
                                                 minRows = 15
  )})
  
  
  output$fteTable <- renderReactable({reactable(altFTE())})
  # output$fteTable <- renderReactable({reactable(FTEs() %>%
  #                                                 select(month, who, FTE), 
  #                                               groupBy = 'month', 
  #                                               defaultPageSize = 12, 
  #                                               columns = list(month = colDef(name = "Month"), 
  #                                                              who = colDef(name = "Personnel"), 
  #                                                              FTE = colDef(aggregate='sum')))})
  
  
  ## Download ----
  ### Create data table ----
  # FIXME - needs updating
  # inputDownloadTable <- reactive({tribble(~category, ~name, ~value,
  #                                         "Training", "Is travel required for counselors to take the TTS training course?", ttsTravelRequired(),
  #                                         "Training", "Approximately how many hours will the counselors have to travel for the course (one way)?" , ttsTravelHours(),
  #                                         "Recurring supervision", "The program team will have regular meetings for to check in onprogram/implementation", checkin(),
  #                                         "Recurring supervision", "How many meetings per month do you anticipate?", checkinRecurrence(),
  #                                         "Wages", "FTTS counselor", hourlySalaryOfCounselor(),
  #                                         "Wages", "Project Director", hourlySalaryOfPD(),
  #                                         "Wages", "Assistant", hourlySalaryOfAssistant(),
  #                                         # "Wages", "Trainer for Counselors", hourlySalaryOfTrainer(),
  #                                         "Wages", "Supervisor", hourlySalaryOfSupervisor(),
  #                                         "Wages", "MD", hourlySalaryOfMD(),
  #                                         "Wages", "Full-Time Equivalents", FTE(),
  #                                         "Wages", "Space Cost per FTE each Month", spaceCostPerFTEperMonth(),
  #                                         "Medication", "Is reconciliation of smoking cessation medication required?", reconciliationRequired(),
  #                                         "Medication", "Will your clinic be providing smoking cessation medication free of charge?", medsProvided(),
  #                                         "Patients", "Number of patients your clinic sees", clinicPatients(),
  #                                         "Patients", "Percent of patients who are smokers", smokerPatients(),
  #                                         "Patients", "Percent of smoking patients that are recruited", eligiblePatients(),
  #                                         "Patients", "Recruiting", patientsRecruited()
  # )
  #   
  # })
  # 
  # 
  # 
  # ### Download ----
  # output$downloadInputs <- downloadHandler(filename = function(){paste0("SmokeFreeSupport_CostsToImplement_", Sys.Date(), ".csv")},
  #                                          contentType="text/csv",
  #                                          content = function(fname){write.csv(inputDownloadTable(), fname, row.names = FALSE)
  #                                          }
  # )
  # 
  
  
}

shinyApp(ui, server)

#}


