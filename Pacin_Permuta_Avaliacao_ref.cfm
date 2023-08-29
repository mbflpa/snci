 <cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
    <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>  
</cfif>    
<!---  --->

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
SELECT Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena, Dir_Descricao, Usu_Matricula
FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
order by Dir_Sigla
</cfquery>
<cfif qAcesso.Usu_Matricula neq '85051071' and qAcesso.Usu_Matricula neq '80144276' and qAcesso.Usu_Matricula neq '85051160' and qAcesso.Usu_Matricula neq '81062117' and qAcesso.Usu_Matricula neq '89094158'>
    <P>TELAS EM FASE DE TESTES</P>
	  <cfabort>  
</cfif> 
<!---  --->
<!--- <cfif trim(qAcesso.Usu_GrupoAcesso) eq 'GESTORMASTER'>
<!---  <cflocation url="Pacin_Permuta_Avaliacao_refb.cfm"> --->
 <cflocation url="index.cfm?opcao=permissao22">
</cfif> --->
<cfquery name="rstpunid" datasource="#dsn_inspecao#">
	SELECT TUN_Codigo, TUN_Descricao
	FROM Tipo_Unidades
	ORDER BY TUN_Descricao
</cfquery>

<cfset auxanoatu = year(now())>

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
	<form action="Pacin_Permuta_Avaliacao.cfm" method="post" target="_blank" name="frmObjeto" onSubmit="return validarform()">
	  <table width="38%" align="center">
       
        <tr>
          <td colspan="5" align="center" class="titulo2"><strong class="titulo1">SOLICITAR PERMUTA POR AVALIA&Ccedil;&Atilde;O DE UNIDADE NO PACIN </strong></td>
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
<cfif UCase(trim(qAcesso.Usu_GrupoAcesso)) eq 'GESTORMASTER'>	
				<cfquery name="rsSE" datasource="#dsn_inspecao#">
					SELECT Dir_Codigo, Dir_Sigla
					FROM Diretoria
					WHERE Dir_Codigo <> '01'
				</cfquery>		
				<select name="frmse" id="frmse" class="form">
    			  <cfoutput query="rsSE">
                      <option value="#Dir_Codigo#">#Dir_Sigla#</option>
                  </cfoutput>
            	</select>	
<cfelse>
            <cfset auxcord = trim(qAcesso.Usu_Coordena)>
			<cfquery name="rsSE" datasource="#dsn_inspecao#">
				SELECT Dir_Codigo, Dir_Sigla FROM Diretoria where dir_codigo in(#auxcord#)
			</cfquery>
			<select name="frmse" id="frmse" class="form">
				  <cfoutput query="rsSE">
		          	<option value="#rsSE.Dir_Codigo#">#Ucase(trim(rsSE.Dir_Sigla))#</option>
				  </cfoutput>
		        </select>
						
</cfif>			
			</td>
          </tr>
		      <tr>
            <td>&nbsp;</td>
            <td width="39%" class="exibir"><strong>Tipo de Unidade &nbsp;&nbsp; : </strong></td>
            <td colspan="2">
			<select name="frmtipounid" class="exibir" id="frmtipounid">
    			  <cfoutput query="rstpunid">
                      <option value="#TUN_Codigo#">#trim(TUN_Descricao)#</option>  
                  </cfoutput>
            </select>			</td>
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
              <div align="center">
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
