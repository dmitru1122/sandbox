<aura:application controller = "HubMemberController">
    <aura:attribute type="String" name="code" default=""/>  
    <aura:attribute type="String" name="state" default=""/> 
    
    <aura:handler name="init" value="{!this}" action="{!c.init}"/>
</aura:application>