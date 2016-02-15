
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

# Car Payment ammortization calculations based on calculations at
# http://faculty.ucr.edu/~tgirke/Documents/R_BioCond/My_R_Scripts/mortgage.R


# Calculate Car Payment

CalculatePaymentAmount<-function(P,n, R) {
    r <- (R/12)/1000
    N <- n
    M <- (P*r)/(1-(1+r)^(-n))
    monthPay <- M
    totalPay <- M*n - P

    return (c(monthPay,totalPay))
}

AmortAmount<-function(P,n, R) {
  r <- (R/12)/1000
  N <- n
  M <- (P*r)/(1-(1+r)^(-n))
  monthPay <- M
  totalPay <- M*n - P
  # Calculate Amortization for each Month
  
  
  Pt <- P # current principal or amount of the loan
  currP <- NULL
  while(Pt>=0) {
    H <- Pt * r # this is the current monthly interest
    C <- M - H # this is your monthly payment minus your monthly interest, so it is the amount of principal you pay for that month
    Q <- Pt - C # this is the new balance of your principal of your loan
    Pt <- Q # sets P equal to Q and goes back to step 1. The loop continues until the value Q (and hence P) goes to zero
    currP <- c(currP, Pt)
  }
  monthP <- c(P, currP[1:(length(currP)-1)])-currP
  aDFmonth <<- data.frame(
    Amortization=c(P, currP[1:(length(currP)-1)]), 
    Monthly_Payment=monthP+c((monthPay-monthP)[1:(length(monthP)-1)],0),
    Monthly_Principal=monthP, 
    Monthly_Interest=c((monthPay-monthP)[1:(length(monthP)-1)],0), 
    Year=sort(rep(1:ceiling(N/12), 12))[1:length(monthP)]
  )
  aDFyear  <- data.frame(
    Amortization=tapply(aDFmonth$Amortization, aDFmonth$Year, max), 
    Annual_Payment=tapply(aDFmonth$Monthly_Payment, aDFmonth$Year, sum), 
    Annual_Principal=tapply(aDFmonth$Monthly_Principal, aDFmonth$Year, sum), 
    Annual_Interest=tapply(aDFmonth$Monthly_Interest, aDFmonth$Year, sum), 
    Year=as.vector(na.omit(unique(aDFmonth$Year)))
  )
  
  #cat (aDFyear)
  return (aDFyear)
}


shinyServer(
  function(input, output) {
    #principalVal <- 100
    #principalVal <- reactive ( {input$carVal}  - {input$tradeVal} - {input$downVal} + {input$otherVal})
    
    # builds a reactive expression that only invalidates 
    # when the value of input$goButton becomes out of date 
    # (i.e., when the button is pressed)
    calcValue <- eventReactive(input$calculate, {
      principalVal <- input$carVal  - input$tradeVal - input$downVal + input$otherVal
      payment <- CalculatePaymentAmount(principalVal,input$termVal,input$termVal)
      payment
    })
    
    AmortValue <- eventReactive(input$calculate, {
      principalVal <- input$carVal  - input$tradeVal - input$downVal + input$otherVal
      payment <- AmortAmount(principalVal,input$termVal,input$termVal)
      payment
    })

    output$carPayment <- renderText(calcValue()[1])
    output$totalPayment <- renderText(calcValue()[2])
    
    output$newBar<- renderPlot({
                                amort <- AmortValue()
                                barplot(t(amort[,c(3,4)]),
                                        col=c("blue", "red"),
                                        main="Annual Interest and Principal Payments",
                                        xlab="Years", ylab="$ Amount",
                                        legend.text=c("Principal", "Interest"),
                                        ylim=c(0, max(amort$Annual_Payment)*1.3))
    })

    
    
  }
)

