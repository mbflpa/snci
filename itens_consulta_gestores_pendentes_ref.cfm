<cfset exibenum = 1>
<!---Cria uma instância do componente Dao teste--->
	<cfobject component = "CFC/Dao" name = "dao">
<!---Invoca o metodo  rsUsuarioLogado para retornar dados do usuï¿½rio logado (rsUsuarioLogado)--->
	<cfinvoke component="#dao#" method="rsUsuarioLogado" returnVariable="rsUsuarioLogado">
    
      
      <cfquery name="qAcesso" datasource="#dsn_inspecao#">
        select Usu_GrupoAcesso, Usu_Lotacao, Usu_DR, Dir_Descricao from usuarios 
        INNER JOIN Diretoria ON Diretoria.Dir_Codigo = Usu_DR
        where Usu_login = '#cgi.REMOTE_USER#'
      </cfquery>

      <cfquery name="rsDEPTO" datasource="#dsn_inspecao#">
        SELECT Dep_Sigla, Dep_Descricao FROM Departamento WHERE Dep_Codigo='#qAcesso.Usu_Lotacao#'
       </cfquery>
	
       <cfquery name="qSE" datasource="#dsn_inspecao#">
        SELECT Dir_Codigo, Dir_Sigla
        FROM Diretoria
        ORDER BY Dir_Sigla ASC
       </cfquery>

<cfset superEstUsuarioLogado = #qAcesso.Dir_Descricao#>

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<link href="css.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
    
function valida_form() {

  var frm = document.forms[0];

        
  	    if (frm.frmdtinic.value=='')
		{
		  alert('Informe a Data Inicial!');
		  frm.frmdtinic.focus();
		  return false;
		}
		
		if (frm.frmdtfim.value=='')
		{
		  alert('Informe a Data Final!');
		  frm.frmdtinic.focus();
		  return false;
		}
		
		if (frm.frmdtinic.value.length != 10)
		{
		alert("Preencher campo: Data Inicial ex. DD/MM/AAAA");
		return false;
	    }
		
		if (frm.frmdtfim.value.length!= 10)
		{
		alert("Preencher campo: Data Final ex. DD/MM/AAAA");
		return false;
	    }
		//alert(frm.frmResp.value);
		if (frm.frmResp.value == 'S'){		
        if(Right(frm.frmdtinic.value,4) != Right(frm.frmdtfim.value,4)){
		   alert("Informar período dentro do mesmo Ano \npara Situação: SOLUCIONADOS");
           return false;
	    }
		}		
        
		var vDia = frm.frmdtinic.value.substr(0,2);
	    var vMes = frm.frmdtinic.value.substr(3,2);
	    var vAno = frm.frmdtinic.value.substr(6,10);
	    var dtini_yyyymmdd = vAno + vMes + vDia
		var vDia = frm.frmdtfim.value.substr(0,2);
	    var vMes = frm.frmdtfim.value.substr(3,2);
	    var vAno = frm.frmdtfim.value.substr(6,10);
	    var dtfim_yyyymmdd = vAno + vMes + vDia
		if (dtini_yyyymmdd > dtfim_yyyymmdd)
	     {
	       alert("Data Inicial maior que a data Final!");
	       return false;
	     }
         
       if(frm.frmResp.value == "")
          {
           alert("Selecione uma Situação!");
           return false;
          }  

           <cfif isDefined("Form.acao") and Form.acao neq "">
            <cfif isDefined("frmSE")>
               <cflocation url="itens_consulta_gestores_pendentes.cfm?dtinicial=#frmdtinic#&dtfinal=#frmdtfim#&frmResp=#frmResp#&frmSE=#frmSE#">
            <cfelse>
              <cflocation url="itens_consulta_gestores_pendentes.cfm?dtinicial=#frmdtinic#&dtfinal=#frmdtfim#&frmResp=#frmResp#"> 
            </cfif>
           </cfif>
  
  } 
    

function Right(str, n){
    if (n <= 0)
       return "";
    else if (n > String(str).length)
       return str;
    else {
       var iLen = String(str).length;
       return String(str).substring(iLen, iLen - n);
    }
    if (a == "" ) 
   {
   alert("Selecionar a área ou órgão subordinador!");
   return false;
    }
}	
    

function Mascara_Data(data)
{
	switch (data.value.length)
	{
		case 2:
		   if (data.value < 1 || data.value > 31) {
		      alert('Valor para o dia inválido!');
			  data.value = '';
		      event.returnValue = false;
			  break;
		    } else {
			  data.value += "/";
				break;
			}
		case 5:
			if (data.value.substring(3,5) < 1 || data.value.substring(3,5) > 12) {
		      alert('Valor para o Mês inválido!');
			  data.value = '';
		      event.returnValue = false;
			  break;
		    } else {
			  data.value += "/";
				break;
			}
	}
}
//=============================
//permite digitaï¿½ao apenas de valores numï¿½ricos
function numericos() {
var tecla = window.event.keyCode;
//permite digitaï¿½ï¿½o das teclas numï¿½ricas (48 a 57, 96 a 105), Delete e Backspace (8 e 46), TAB (9) e ESC (27)
//if ((tecla != 8) && (tecla != 9) && (tecla != 27) && (tecla != 46)) {

	if ((tecla != 46) && ((tecla < 48) || (tecla > 57))) {
		event.returnValue = false;
	}
}

function exibe(a){
  <cfoutput>
   document.getElementById('divSE').style.visibility = 'hidden';
   document.getElementById('frmSE').value = '';
     if (a == 'N' || a=='S' || a=='R' ) {
        document.getElementById('divSE').style.visibility = 'visible';
        document.getElementById('frmSE').value = '#qAcesso.Usu_DR#';
     }else{
        document.getElementById('divSE').style.visibility = 'hidden';
        document.getElementById('frmSE').value = '';
     }
    </cfoutput>
   }    

</script>
</head>

<body onload="exibe(0)">
<cfinclude template="cabecalho.cfm">
<p align="center">
  <!--- Ãrea de conteÃºdo   --->
</p>

<form action="itens_consulta_gestores_pendentes_ref.cfm" method="post" onSubmit="return valida_form();" enctype="multipart/form-data"  target="_blank" name="frmopc" >
      <table width="44%" align="center">
	  <tr>
		
        <td>&nbsp;</td>
      </tr>
	  
      <tr>
        <td colspan="2"><p align="center" class="titulo1"><strong><br>
          PONTOS DE CONTROLE INTERNO POR DEPARTAMENTO</strong></p>
            <p class="exibir"></td>
      </tr>
      <tr>
        <td>&nbsp;</td>
      </tr>
      
        
		<tr>
          <td ><div id="consultaSitData" >

             <span class="exibir"><strong>&nbsp;&nbsp;&nbsp;Situação:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong></span>
             <select name="frmResp" class="form" id="frmResp" onchange="exibe(this.value)">
                 <option value="" selected>Selecione uma Situação</option>
                <option value="N">NÃO SOLUCIONADOS</option>
                <option value="S">SOLUCIONADOS</option>
                <option value="A">APURAÇÃO</option> 
                <cfif find("DERAT", rsDEPTO.Dep_Sigla) gt 0>
                  <option value="R">REDE TERCEIRIZADA</option>
                </cfif>
                <option value="C">CORPORATIVOS</option>
             </select>
              <br><br>
             <cfset inic = '01/01/' & year(now())>
		         <cfset fim = '31/12/' & year(now())> 
             <span class="exibir"><strong>&nbsp;&nbsp;Data Inicial:&nbsp;</strong> </span>
             <strong class="titulo1"><input name="frmdtinic" type="text" class="form" id="frmdtinic" tabindex="1"  size="13" maxlength="10" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" value="<cfoutput>#inic#</cfoutput>"></strong> 
             <span class="exibir"><strong>&nbsp;&nbsp;Data Final:&nbsp;</strong> </span>
             <strong class="titulo1"><input name="frmdtfim" type="text" class="form" id="frmdtfim" tabindex="2" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" size="13" maxlength="10"  value="<cfoutput>#fim#</cfoutput>"></strong> 
             <br><br>
             <div id="divSE" >
              <span class="exibir"><strong>&nbsp;&nbsp;&nbsp;SE:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong></span>
                <select name="frmSE" class="form" id="frmSE"  >
                <cfoutput query="qSE">
                  <option value="#Dir_Codigo#" <cfif #Dir_Codigo# is #qAcesso.Usu_DR#>selected</cfif>>#Dir_Sigla#</option>
                </cfoutput>
                </select>
            </div>
            
            
            </div>
           </td>
        </tr>
        <tr>
           <td>&nbsp;</td>
        </tr>
      <tr>
        <tr>
        <td><div align="center">
          <input name="Confirmar" type="submit" class="exibir" id="Confirmar" value="Confirmar" >
        </div></td>
		</tr>
  </table>
  <input name="acao" type="hidden" value=2>
</form>
</body>
</html>