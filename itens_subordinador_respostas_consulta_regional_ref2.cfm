<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<td align="center"><cfinclude template="cabecalho.cfm"></td>
<cfset ckTipo = #URL.ckTipo#/>
<script language="javascript">	
function Right(str, n){
    if (n <= 0)
       return "";
    else if (n > String(str).length)
       return str;
    else {
       var iLen = String(str).length;
       return String(str).substring(iLen, iLen - n);
    }
}	
	
	
function troca(a,b,c){
 //alert(a + b + c);
if (a == "" ) 
   {
   alert("Selecionar a área ou órgão subordinador!");
   return false;
    }
<cfoutput>	
 var ckTipo = '#ckTipo#';

if(ckTipo==1){	
 if ((b.length != 0 ||  c.length != 0) && (b.length != 10 || c.length != 10))
   {
   alert("Preencher campos datas ex. dd/mm/aaaa");
   return false;
  }
}else{
    if (b.length != 10){
        alert("Preencher campo: Data Inicial ex. DD/MM/AAAA");
        return false;
    }
    if (c.length!= 10){
        alert("Preencher campo: Data Final ex. DD/MM/AAAA");
        return false;
    }
	
	if(Right(b,4) != Right(c,4)){
		alert("Informe o período dentro do mesmo ano!");
        return false;
		
	}
}	
</cfoutput>	
// sem falhas 
document.form.submit();
}
	
function numericos() {
var tecla = window.event.keyCode;
//permite digitação das teclas numéricas (48 a 57, 96 a 105), Delete e Backspace (8 e 46), TAB (9) e ESC (27)
if ((tecla != 8) && (tecla != 9) && (tecla != 27) && (tecla != 46)) {
	if ((tecla < 48) || (tecla > 57)) {
	//  if () {
		event.returnValue = false;
	 // }
	}
}
}
//================
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
</script>

<cfquery name="rsPermissaoSubordinadorRegional" datasource="#dsn_inspecao#">
	SELECT Usu_Login, Usu_Lotacao, Usu_GrupoAcesso, Usu_DR, Usu_LotacaoNome
	FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#' and Usu_GrupoAcesso = 'SUBORDINADORREGIONAL'
	ORDER BY Usu_Lotacao ASC
</cfquery>
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_Lotacao, Usu_DR from usuarios where Usu_login = '#cgi.REMOTE_USER#'
</cfquery>
<!---   <cfdump var="#rsPermissaoSubordinadorRegional#"> --->

<cfquery name="qReop" datasource="#dsn_inspecao#">
   SELECT DISTINCT Rep_Codigo, Rep_Sigla
   FROM Reops INNER JOIN Areas ON Reops.Rep_CodArea = Areas.Ars_Codigo WHERE Rep_Status = 'A' AND Reops.Rep_CodArea = '#rsPermissaoSubordinadorRegional.Usu_Lotacao#' AND Reops.Rep_Codigo <> '#rsPermissaoSubordinadorRegional.Usu_Lotacao#' 
   ORDER BY Rep_Sigla
</cfquery>
<cfquery name="qArea" datasource="#dsn_inspecao#">
	SELECT Ars_Codigo, Ars_Sigla, Ars_Descricao From Areas WHERE Ars_Status = 'A' AND Ars_Codigo = '#rsPermissaoSubordinadorRegional.Usu_Lotacao#'
</cfquery>
<cfset areaCodigo = "#qArea.Ars_Codigo#"/>	
<cfset areaSigla = "#qArea.Ars_Sigla#"/>
	
<!--- <cfdump var="#qReop#"> --->
<link href="css.css" rel="stylesheet" type="text/css">

</head>

<body>
<p align="center">
  <!--- Área de conteúdo   --->
</p>
<form  method="get" name="form" target="_blank" action="itens_subordinador_respostas_pendentes_subordinador_regional.cfm" id="form">
      <table width="85%" align="center"><br><br><br>
	     <tr>
			 <input name="cktipo" type="hidden" id="cktipo" value="<cfoutput>#ckTipo#</cfoutput>">  
	 	     <td colspan="5">&nbsp;</td>
         </tr>
      <tr>
		  <cfif ckTipo eq 1>
			   <td colspan="5" align="center" class="titulo1"><strong><cfoutput>Pontos Pendentes - #qArea.Ars_Descricao#</cfoutput></strong></td>
		  </cfif>
		  <cfif ckTipo eq 2>
			   <td colspan="5" align="center" class="titulo1"><strong><cfoutput>Pontos Finalizados - #qArea.Ars_Descricao#</cfoutput></strong></td>
		  </cfif>
          
      </tr>
	      <tr>
	 	      <td colspan="5">&nbsp;</td>
         </tr>
		<input name="reop" type="hidden" id="reop" value="<cfoutput>#rsPermissaoSubordinadorRegional.Usu_Lotacao#</cfoutput>">
	 	    <tr>
	 	      <td colspan="5">&nbsp;</td>
           </tr>
		    <tr>
		    <td align="right"><span class="exibir"><strong><label title="label">Selecione a área ou órgão subordinador:</label></strong></span></td>
		    <td colspan="4" align="left"><select name="cbReop" class="form">
			<cfoutput>
			  <option value=#areaCodigo# selected>#areaSigla#</option>	
			</cfoutput>	
			  <cfoutput query="qReop">
                <option value="#Rep_Codigo#">#Rep_Sigla#</option>
              </cfoutput>
		      <option value="todos">TODOS OS ÓRGÃO/UNIDADES SUBORDINADOS</option>
            </select></td>
		    </tr>
		     <tr>
	 	      <td colspan="5">&nbsp;</td>
            </tr>
		  <cfif ckTipo eq 1 >
		    <tr>
              <td colspan="2" align="center" ><span class="exibir"><strong>Atenção! A indicação de um período é opcional.</strong></span></td>
              
            </tr>
		    <tr>
	 	      <td colspan="5">&nbsp;</td>
            </tr>
		  </cfif>
            <tr>
              <td align="right"><span class="exibir"><strong>Data Inicial:</strong></span></td>
              <td><span class="exibir"><input name="dtinic" type="text" vazio="false" nome="Data Inicial" tabindex="1" size="14" maxlength="10" class="form" onKeyDown="Mascara_Data(this)" onKeyPress="numericos()">
              </span></td>
            </tr>
            <tr>
              <td align="right"><span class="exibir"><strong>Data Final:&nbsp;&nbsp;</strong></span></td>
              <td><span class="exibir"><input name="dtfinal" type="text" tabindex="2" size="14" vazio="false" nome="Data Final" maxlength="10" class="form" onKeyDown="Mascara_Data(this)" onKeyPress="numericos()">
              </span></td>
            </tr>
		  
      <tr>
        <td colspan="5">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="5" align="center"><input name="Submit2" type="button" class="botao" value="Confirmar" onClick="troca(cbReop.value,dtinic.value,dtfinal.value)"></td>
	  </tr>
      </table>
</form>
</body>
</html>
