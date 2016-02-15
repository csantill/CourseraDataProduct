
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
# http://www.wikihow.com/Calculate-a-Car-Loan-in-Excel

library(shiny)


shinyUI(pageWithSidebar(
  headerPanel("Car Payment Calculator"),
  sidebarPanel(
    h3('Sidebar text'),
    numericInput("carVal",label = h3("Car Sale Price"),  20000),
    numericInput("tradeVal", label = h3("Trade-in Value"), value = 0),
    numericInput("downVal", label = h3("Down Payment"), value = 0),
    numericInput("otherVal", label = h3("Other Charges"), value = 0),
    numericInput("interestVal", label = h3("Interest Rate (%APR)"), value = 6,min=0,max = 100),
    numericInput("termVal", label = h3("Term of Loan (Month)"), value = 60,min=0,step=12),
    hr(),
    actionButton('calculate',"Calculate")

  ),
  mainPanel(
    
    h3('Car Payment'),
    h4('Monthly Car Payment :'),
    textOutput("carPayment"),
    hr(),
    h4('Total interest Payment :'),
    textOutput("totalPayment"),
    plotOutput('newBar')
  )
))