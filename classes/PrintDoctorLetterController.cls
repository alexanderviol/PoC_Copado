/*
 * Class Responsible for generating the the selected document to be printed from the lightning component Doctor Letter selection
 * @ author  emma
 * @ created 2018-04-23  
 */ 
public class PrintDoctorLetterController {
    public boolean renderDocL{get; set;}
    public boolean renderDocLw{get; set;}
    
    public PrintDoctorLetterController (){
        try{
             renderDocL = Boolean.valueOf(Apexpages.currentPage().getParameters().get('docL'));
             renderDocLw = Boolean.valueOf(Apexpages.currentPage().getParameters().get('docLw'));
            
        }
        catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);  
        }
        
    }

}