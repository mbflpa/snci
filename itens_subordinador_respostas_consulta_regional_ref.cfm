<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<td align="center"><cfinclude template="cabecalho.cfm"></td>

<script language="javascript">
function troca(a,b,c){
 //alert(a + b + c);
if (a == "" || b == "" || c == "") 
   {
   alert("Informar o valor de um ou mais campo(s)!");
   return false;
    }
if (b.length != 10 || c.length != 10)
   {
   alert("Preencher campos datas ex. dd/mm/aaaa");
   return false;
  }
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

<!---   <cfdump var="#rsPermissaoSubordinadorRegional#"> --->

<cfquery name="qReop" datasource="#dsn_inspecao#">
   SELECT DISTINCT Rep_Codigo, Rep_Sigla
   FROM Reops INNER JOIN Areas ON Reops.Rep_CodArea = Areas.Ars_Codigo WHERE Rep_Status = 'A' AND Reops.Rep_CodArea = '#rsPermissaoSubordinadorRegional.Usu_Lotacao#'
   ORDER BY Rep_Sigla
</cfquery>
<!--- <cfdump var="#qReop#"> --->
<link href="css.css" rel="stylesheet" type="text/css">

</head>

<body>
<p align="center">
  <!--- Área de conteúdo   --->
</p>
<form  method="post" name="form" action="itens_subordinador_respostas_consulta_regional.cfm" id="form">
      <table width="85%" align="center"><br><br><br>
	     <tr>
	 	     <td colspan="5">&nbsp;</td>
         </tr>
      <tr>
          <td colspan="5" align="center" class="titulo1"><strong><cfoutput>#rsPermissaoSubordinadorRegional.Usu_LotacaoNome#</cfoutput></strong></td>
      </tr>
	      <tr>
	 	      <td colspan="5">&nbsp;</td>
         </tr>
		<input name="reop" type="hidden" id="reop" value="<cfoutput>#rsPermissaoSubordinadorRegional.Usu_Lotacao#</cfoutput>">
	 	    <tr>
	 	      <td colspan="5">&nbsp;</td>
           </tr>
		    <tr>
		    <td align="right"><span class="exibir"><strong><label title="label">Selecione a &aacute;rea:</label></strong></span></td>
		    <td colspan="4" align="left"><select name="cbReop" class="form">
              <option selected="selected" value="32436422">---</option>
              <cfoutput query="qReop">
                <option value="#Rep_Codigo#">#Rep_Sigla#</option>
              </cfoutput>
            </select></td>
		    </tr>
		     <tr>
	 	      <td colspan="5">&nbsp;</td>
            </tr>
            <tr>
              <td align="right"><span class="exibir"><strong>Data Inicial:</strong></span></td>
              <td><span class="exibir"><input name="dtinic" type="text" vazio="false" nome="Data Inicial" tabindex="1" size="14" maxlength="10" class="form" onKeyDown="Mascara_Data(this)" onKeyPress="numericos()">
              </span></td>
            </tr>
            <tr>
              <td align="right"><span class="exibir"><strong>Data Final:</strong></span></td>
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
