<cfset evento = 'document.frm1.arquivo.focus()'>
<!---
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>
 --->
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_Lotacao from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<cfif Trim(qAcesso.Usu_GrupoAcesso) eq 'DESENVOLVEDORES' or Trim(qAcesso.Usu_GrupoAcesso) eq 'GESTORES' or Trim(qAcesso.Usu_GrupoAcesso) eq 'PRESIDENCIA' or Trim(qAcesso.Usu_GrupoAcesso) eq 'VICE-PRESIDENCIA' or Trim(qAcesso.Usu_GrupoAcesso) eq 'GESTOR-CORPORATIVO'>

<html>
<head>
<title>Sistema de Acompanhamento - Follow-up</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
</head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<body text="#FFFFFF" link="#FFFFFF" vlink="#FFFFFF" alink="#FFFFFF" class="link1">

<br><br><br><br><br>

<cfinclude template="cabecalho.cfm">
<!---    <tr>
		<td class="titulo1"><br />
		<b>&nbsp;Caro Usu�rio,<br /><br />
		</b><br /></td>

	</tr>
	<tr>
	  <td colspan="2" class="titulo1"><b>&nbsp;Visando melhorar a identifica��o dos
documentos, recomendamos que sejam observados os seguintes aspectos para
atribui��o de nomes aos documentos(anexos):<br /></b><br /></td>
	</tr>
	<tr>
	<td colspan="2" class="titulos"><ul>
		<br /><li>&nbsp;N�o utilizar caracteres especiais, tais como: cedilha (�), asterisco (*),
par�nteses ( ), colchetes [ ], percentual (%), acentos etc. Se for necess�rio,
utilizar o h�fen (-) para separar mais de um nome.<br />
        </li>
      </ul
	></tr>
	<tr>
	<td colspan="2" class="titulos"><ul>
		<li>&nbsp;N�o utilizar espa�os em branco (barra de espa�o) entre os nomes, pois alguns
sistemas operacionais n�o conseguem interpreta-los, principalmente quando os
arquivos s�o publicados na internet.<br />
        </li>
      </ul
	></tr>
	<tr>
	<td colspan="2" class="titulos"><ul>
		<li>&nbsp;Evitar atribuir nomes excessivamente grandes.<br />
        </li>
      </ul
	></tr>
	<tr>
	<td colspan="2" class="titulo1"><ul>
		<li>&nbsp;Utilizar apenas letras min�sculas, pois alguns sistemas operacionais distinguem
mai�sculas de min�sculas.<br />
        </li>
      </ul
	></tr>
	<tr>
	<td colspan="2" class="titulo1"><ul>
		<li>&nbsp;Sugerimos que os documentos sejam nomeados com a sigla da
�rea para maior facilidade de identifica��o.<br />
        </li>
      </ul
	></tr>

	<tr>
	<td class="titulo1"><ul>
	<li>&nbsp;Tabela de Sugest�es para nomear documentos:
    </td><br><br><br>

<table border="1" align="center">
  <tr class="titulo1" align="center">
    <td>Nome do documento</td>
    <td>Nome do arquivo</td>
  </tr>
  <tr class="titulo1">
    <td>Planilha de Previs�o de gastos da AUDIT 2002</td>
    <td>pl-audit-gastos-02</td>
  </tr>
  <tr class="titulo1">
    <td>Portaria PRESI 136/2002</td>
    <td>port-presi-136-02</td>
  </tr>
  <tr class="titulo1">
    <td>Memorando 12/02 da VIGEP</td>
    <td>memo-vigep-12-02</td>
  </tr>
  <tr class="titulo1">
    <td>Resolu��o CECOM 37/1998</td>
    <td>res-cecom-37-98</td>
  </tr>
</table>--->

<br><br><br><br>

<form name="frm1" action="itens_usuarios_receber_anexo.cfm" enctype="multipart/form-data" method="post">

<table width="80%" border="0" align="center">
  <tr>
    <td colspan="2" class="titulo1">Envio de arquivo anexo</td>
    </tr>
  <tr>
    <td width="18%">&nbsp;</td>
    <td width="82%">&nbsp;</td>
  </tr>
  <tr>
    <td class="titulos">Arquivo:</td>
    <td><input name="arquivo" class="botao" type="file" size="100"></td>
  </tr>
  <tr>
   <td class="titulos">&nbsp;</td>
   <td>
	   <input type="hidden" name="numero_inspecao" size="16" class="form" value="<cfoutput>#url.ninsp#</cfoutput>">
	   <input type="hidden" name="numero_unidade" size="16" class="form" value="<cfoutput>#url.unid#</cfoutput>">
	   <input type="hidden" name="numero_item" size="16" class="form" value="<cfoutput>#url.nitem#</cfoutput>">
	   <input type="hidden" name="numero_area" size="16" class="form" value="<cfoutput>#URL.area#</cfoutput>">
	   <input type="hidden" name="numero_recomendacao" size="16" class="form" value="<cfoutput>#url.nrecom#</cfoutput>">
	   <input type="hidden" name="situacao" size="16" class="form" value="<cfoutput>#url.situacao#</cfoutput>">
       <input type="hidden" name="vitem" size="16" class="form" value="<cfoutput>#url.vitem#</cfoutput>">
   </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td><input name="confirmar" type="submit" class="botao" value="Anexar"></td>
  </tr>
</table>
</form>
</body>
</html>

<cfelse>
     <cfinclude template="permissao_negada.htm">
</cfif>