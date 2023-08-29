<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
    <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>  
</cfif>      
<!---  --->
<cfset auxanoatu = year(now())>
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
SELECT Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena, Dir_Descricao, Usu_Matricula
FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
order by Dir_Sigla
</cfquery>

<cfquery name="rsSE" datasource="#dsn_inspecao#">
	SELECT distinct Left([PPU_DEUnidade],2) AS codse, Dir_Sigla
	FROM PacinPermutaUnidade, Diretoria
	WHERE PPU_Ano ='#auxanoatu#' AND PPU_Status='S' AND Left([PPU_DEUnidade],2)=[Dir_Codigo]
</cfquery>

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<script language="javascript">

function validarform() {
//alert('aqui....');
    var frm = document.forms[0];
	var messelec = frm.frmmes.value;
	var mesatual = frm.frmmesatual.value;
//alert(frm.frmUsuGrupoAcesso.value);
//alert(frm.frmdia.value);

	//alert('frmanoselecionado ' + frm.frmano.value + ' Ano atual ' + frm.frmanoatual.value + ' Mes selecionado ' + frm.frmmes.value + ' mes atual: ' + mesatual);	
	if (eval(frm.frmano.value) == eval(frm.frmanoatual.value))
	{
	if (eval(messelec) >= eval(mesatual)){
	alert('Gestor(a), o mês selecionado para o ano selecionado ainda não gerado!');
	return false;
	}

    if (eval(messelec) == eval(mesatual - 1) && frm.frmUsuGrupoAcesso.value != 'GESTORMASTER' && frm.frmdia.value <= 10){
	alert('Gestor(a), o mês selecionado para o ano selecionado ainda não gerado!');
	return false;
	}	
	} 


//return false;
}
</script>
 <link href="css.css" rel="stylesheet" type="text/css">
</head>
<br>
<body>

<!--- <cfinclude template="cabecalho.cfm"> --->
<tr>
   <td colspan="6" align="center">&nbsp;</td>
</tr>

<!--- Área de conteúdo   --->
	<form action="Pacin_Permuta_Avaliacaob.cfm" method="post" target="_blank" name="frmObjeto" onSubmit="return validarform()">
	  <table width="50%" align="center">
       
        <tr>
          <td colspan="5" align="center" class="titulo2"><strong>AUTORIZAR SUBSTITUI&Ccedil;&Atilde;O DE UNIDADE PARA AVALIA&Ccedil;&Atilde;O NO PACIN</strong></td>
        </tr>
		<tr>
          <td colspan="5" align="center" class="titulo1">&nbsp;</td>
        </tr>
        <tr>
          <td colspan="5" align="center">&nbsp;</td>
        </tr>
        <tr>
          <td colspan="5" align="center"><div align="left"><strong class="titulos">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Filtro de sele&ccedil;&atilde;o:
            
          </strong></div></td>
        </tr>
        <tr>
          <td width="2%"></td>
          <td colspan="4"><strong>
          </strong><strong><span class="exibir">
          </span></strong></td>
        </tr>
 
          <tr>
            <td>&nbsp;</td>
            <td width="39%" class="exibir"><strong>Superintend&ecirc;ncia : </strong></td>
            <td width="59%" colspan="2">

            <cfset auxcord = trim(qAcesso.Usu_Coordena)>
			    <select name="frmse" id="frmse" class="form">
				  <cfoutput query="rsSE">
		          	<option value="#rsSE.codse#">#Ucase(trim(rsSE.Dir_Sigla))#</option>
				  </cfoutput>
		        </select> 		</td>
          </tr>

		  <cfset cont = 0>		  
          <tr>
            <td>&nbsp;</td>
            <td class="exibir"><strong>Exerc&iacute;cio &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: </strong></td>
            <td colspan="2">
			<select name="frmano" class="exibir" id="frmano">
                <option value="<cfoutput>#auxanoatu#</cfoutput>"><cfoutput>#auxanoatu#</cfoutput></option>
            </select></td>
          </tr>
          <td>&nbsp;</td>
            <td colspan="3">
              
              <div align="right">
                <input name="Submit1" type="submit" class="botao" id="Submit1" value="Confirmar">
              </div></td></tr>
        <tr>
          <td>&nbsp;</td>
          <td colspan="3">&nbsp;</td>
        </tr>
      </table>
	  
	</form>
</body>
</html>
