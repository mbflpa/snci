<!---   <cftry>    
  <cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>   --->  
<cfset nomearquivo = ListLast(trim(form.numero_inspecao),'\')> 
<cfset form.numrelat = left(nomearquivo,10)>

<!---  --->
<cfset sdtatual = dateformat(now(),"YYYYMMDDHH")>
<cfset sdtarquivo = dateformat(now(),"YYYYMMDDHH")>
<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
<cfset slocal = #diretorio# & 'Dados\'>

<!--- <cfdirectory name="qList" filter="*.*" sort="name desc" directory="#slocal#"> --->
<cfdirectory name="qList" filter="*.*" sort="name asc" directory="#slocal#">
<cfoutput query="qList">
   <cfset sdtarquivo = dateformat(dateLastModified,"YYYYMMDDHH")> 
   <cfif form.numrelat eq left(name,10)>
	    <cffile action="delete" file="#slocal##name#">
   <cfelse>
	   <cfif left(sdtatual,8) eq left(sdtarquivo,8)>
			<cfif (right(sdtatual,2) - right(sdtarquivo,2)) gte 2>
			   <cffile action="delete" file="#slocal##name#">  
			</cfif>
	   <cfelseif left(sdtatual,8) gt left(sdtarquivo,8)>
		<cffile action="delete" file="#slocal##name#">
	   </cfif>
  </cfif>
</cfoutput>
<!--- <cfset gil = gil> --->
<!---  --->
 
<cfif len(nomearquivo) neq 23>
	 <cfoutput>
		  <cflocation url="arquivo_dbins_RejeitarXML.cfm?form.motivo=Nome do arquivo fora padrao do SGI-v6 ex. SE99999999_99999999.xml!&form.numrelat=#form.numrelat#&form.numunid=''&form.dtiniinsp=''&form.nomearquivo=#nomearquivo#&form.excluirsn=N">
	 </cfoutput>
</cfif>


<cfset ano_aux = right(form.numrelat,4)>
<cfset anoAtual = year(now())>
<cfif ano_aux neq anoAtual > 
     <cfoutput>
		<cflocation url="arquivo_dbins_RejeitarXML.cfm?form.motivo=O ano que consta no numero do relatorio e invalido para este exercicio de inspecao!&form.numrelat=#form.numrelat#&form.numunid=''&form.dtiniinsp=''&form.nomearquivo=#nomearquivo#&form.excluirsn=N">
	 </cfoutput>
</cfif>

<!---  --->
<cfset smatric = mid(nomearquivo,12,8)>
<cfquery datasource="#dsn_inspecao#" name="rsFunc">
  SELECT Fun_Matric FROM Funcionarios WHERE Fun_Matric = '#smatric#'
</cfquery>
<cfif rsFunc.recordcount is 0>
 <cfoutput>
	  <cflocation url="arquivo_dbins_RejeitarXML.cfm?form.motivo=Arquivo com nome fora do padrao do SGI ou Falta a identificacao do Inspetor no SNCI&form.numrelat=#left(form.numero_inspecao,10)#&form.numunid=''&form.dtiniinsp=''&form.nomearquivo=#nomearquivo#&form.excluirsn=N">
</cfoutput>
</cfif>


<!---  --->
<cfif isDefined("Form.arquivo")>

<!---      excluir arquivo existente no diretorio dados --->
     <cfset arquivo = GetDirectoryFromPath(gettemplatepath()) & 'dados\' & #Form.numero_inspecao#>
	 
	<!--- Enviando o arquivo inspecao.xml na pasta dados no servidor --->
	 <cffile action="upload" filefield="arquivo" destination="#GetDirectoryFromPath(GetTemplatePath())#Dados" nameconflict="makeunique" accept="application/x-xml,text/xml"> 
	
	<!--- Lendo o arquivo teste.xml na pasta dados no servidor --->
    <cffile action="read" file="#GetDirectoryFromPath(gettemplatepath())#Dados\#form.numero_inspecao#" variable="XmlDoc" charset="iso-8859-1">
<!---  <cfoutput>
 form.arquivo: #Form.arquivo#<br>
 form.numero: #form.numero_inspecao#<br>
 form.numrelat: #form.numrelat#<br>
 arquivo: #arquivo#<br>
 </cfoutput>  --->
<!---  <cfset gil = gil>	 --->
	<!---Converte o string pra documento XML--->
    <cfset XmlDoc = Replace(XmlDoc, "&", "&amp;", "All")>
    <cfset xml = XmlParse(XmlDoc)>

	<!---O array apresenta o tipo de arquivo + o nome da chave + o nome da chave primaria do xml --->
	
	<!--- Armazena dados do arquivo xml (índice do vetor = 1, primeiro registro do arquivo xml) --->
	<!--- <cfset STO = xml.rootelement.dados[1].RIP_Unidade.XmlText>
	<cfset Numero = xml.rootelement.dados[1].RIP_NumInspecao.XmlText>
	<cfset Data = xml.rootelement.dados[1].INP_DtInicInspecao.XmlText> --->
	<cfset RIPUnidade = trim(xml.rootelement.dados[1].RIP_Unidade.XmlText)>
	<cfset RIPInspecao = trim(xml.rootelement.dados[1].RIP_NumInspecao.XmlText)>
	<cfset anoinsp = right(RIPInspecao,4)>
	<cfset INPDtInicInsp =  trim(xml.rootelement.dados[1].INP_DtInicInspecao.XmlText)>
	<cfset RIPAno = right(trim(RIPInspecao),4)>
	<cfif INPDtInicInsp eq "00:00:00">
	   <cfset INPDtInicInsp = DateFormat(now(),"dd/mm/yyyy")>
    </cfif>
	<!---  --->
	   <cfquery datasource="#dsn_inspecao#">
		DELETE FROM Andamento WHERE AND_NumInspecao = '#RIPInspecao#'
	   </cfquery>
	   <cfquery datasource="#dsn_inspecao#">
		DELETE FROM ParecerCausaProvavel WHERE PCP_Inspecao = '#RIPInspecao#'
	   </cfquery>
	   <cfquery datasource="#dsn_inspecao#">
		DELETE FROM ParecerUnidade WHERE Pos_Inspecao = '#RIPInspecao#'
	   </cfquery>
		<cfquery datasource="#dsn_inspecao#">
		DELETE FROM ProcessoParecerUnidade WHERE Pro_Inspecao = '#RIPInspecao#'
	   </cfquery>
	   <cfquery datasource="#dsn_inspecao#">
		DELETE FROM Resultado_Inspecao WHERE RIP_NumInspecao = '#RIPInspecao#'
	   </cfquery>
	   <cfquery datasource="#dsn_inspecao#">
		DELETE FROM Inspetor_Inspecao WHERE IPT_NumInspecao = '#RIPInspecao#'
	   </cfquery>
	   <cfquery datasource="#dsn_inspecao#">
		DELETE FROM Inspecao WHERE INP_NumInspecao = '#RIPInspecao#'
	   </cfquery>
	   <cfquery datasource="#dsn_inspecao#">
		DELETE FROM Numera_Inspecao WHERE NIP_NumInspecao = '#RIPInspecao#'
	   </cfquery>
       <cfquery datasource="#dsn_inspecao#">
        DELETE FROM Analise WHERE Ana_NumInspecao = '#RIPInspecao#'
       </cfquery>
	<!---  --->
     <!--- critica do Nº da Inspeção e o da Unidade--->
    <cfif len(RIPInspecao) neq 10 or len(RIPUnidade) neq 8>
         <cfoutput>
              <cflocation url="arquivo_dbins_RejeitarXML.cfm?form.motivo=Nro da Inspecao e/ou Nro da Unidade fora do padrao&form.numrelat=#RIPInspecao#&form.numunid=#RIPUnidade#&form.dtiniinsp=#INPDtInicInsp#&form.nomearquivo=#nomearquivo#&form.excluirsn=N">
         </cfoutput>
    </cfif>
	
	<!--- critica do batimento do ano da inspeção com o exercício da inspeção--->
    <cfif right(RIPInspecao,4) neq RIPANO>
         <cfoutput>
              <cflocation url="arquivo_dbins_RejeitarXML.cfm?form.motivo=O Ano da Avalição difere ao do exercicio realizado informado&form.numrelat=#RIPInspecao#&form.numunid=#RIPUnidade#&form.dtiniinsp=#INPDtInicInsp#&form.nomearquivo=#nomearquivo#&form.excluirsn=N">
         </cfoutput>
    </cfif>
	
	<!--- critica do status da unidade inspecionada se foi desativada--->
	<cfquery datasource="#dsn_inspecao#" name="rsCrit">
     SELECT Und_Descricao, Und_Status FROM Unidades WHERE Und_Codigo = '#RIPUnidade#'
    </cfquery>

    <cfif rsCrit.Und_Status eq 'D'>
         <cfoutput>
              <cflocation url="arquivo_dbins_RejeitarXML.cfm?form.motivo=Unidade desativada no SNCI&form.numrelat=#RIPInspecao#&form.numunid=#RIPUnidade#&form.dtiniinsp=#INPDtInicInsp#&form.nomearquivo=#nomearquivo#&form.excluirsn=N">
         </cfoutput>
    </cfif>
	<!--- critica do duplicata do nro da inspeção --->
	<cfquery datasource="#dsn_inspecao#" name="rsCrit">
     select NIP_Unidade FROM Numera_Inspecao WHERE NIP_Unidade = '#RIPUnidade#' and NIP_NumInspecao = '#RIPInspecao#'
    </cfquery>

    <cfif rsCrit.recordcount gt 0>
         <cfoutput>
              <cflocation url="arquivo_dbins_RejeitarXML.cfm?form.motivo=Nro da Inspecao ja cadastrado na tabela Numera_Inspecao!&form.numrelat=#RIPInspecao#&form.numunid=#RIPUnidade#&form.dtiniinsp=#INPDtInicInsp#&form.nomearquivo=#nomearquivo#&form.excluirsn=N">
         </cfoutput>
    </cfif>

	<!--- Existencia dos Inspetores no SNCI --->
	<cfset inspetorSN = 'S'>
	<cfset msginsp = "">
	<cfset numocor = 1>
	<cfloop from="1" to="#val(Len(xml.rootelement.dados[1].IPT_MatricInspetor.XmlText) / 8)#" index="j">
	    <cfset smatr = mid(xml.rootelement.dados[1].IPT_MatricInspetor.XmlText,numocor,8)>

		<cfquery datasource="#dsn_inspecao#" name="rsFunc">
		  SELECT Fun_Matric FROM Funcionarios WHERE Fun_Matric = '#smatr#'
		</cfquery>
	    <cfif rsFunc.recordcount is 0>
		 	<cfset inspetorSN = 'N'>
			<cfoutput>
                <cflocation url="arquivo_dbins_RejeitarXML.cfm?form.motivo=Um ou mais Inspetor(es) sem cadastro no SNCI&form.numrelat=#RIPInspecao#&form.numunid=#RIPUnidade#&form.dtiniinsp=#INPDtInicInsp#&form.nomearquivo=#nomearquivo#&form.excluirsn=N">
            </cfoutput>
			<cfset msginsp = "">
		</cfif>
		<cfset numocor = numocor + 8>
	</cfloop>
	<!--- fim existencia do inspetor --->
	 <!--- Critica existência do ponto no banco SNCI --->
	 <cfset inpModalidade = #xml.rootelement.dados[1].INP_Modalidade.XmlText#>
	<cfquery name="qVerificaTipoUnidade" datasource="#dsn_inspecao#">
	  SELECT Und_Codigo, Und_CodReop, Und_TipoUnidade FROM Unidades
	  WHERE Und_Codigo = '#xml.rootelement.dados[1].RIP_Unidade.XmlText#'
	</cfquery>
	<cfloop from="1" to="#ArrayLen(xml.rootelement.dados)#" index="i">
    
	<cfquery name="qValidar" datasource="#dsn_inspecao#">
	SELECT itn_situacao from Itens_Verificacao inner join TipoUnidade_ItemVerificacao on Itn_NumItem = TUI_ItemVerif and Itn_NumGrupo = tui_grupoItem
	where itn_situacao = 'A' and tui_Ano = '#anoinsp#' and tui_modalidade = '#xml.rootelement.dados[1].INP_Modalidade.XmlText#' and tui_TipoUnid=#qVerificaTipoUnidade.Und_TipoUnidade# and TUI_GrupoItem = #xml.rootelement.dados[i].RIP_NumGrupo.XmlText# and TUI_ItemVerif = #xml.rootelement.dados[i].RIP_NumItem.XmlText#
	</cfquery>
	<cfif qValidar.recordcount lte 0>
	     <cfoutput>
		      <cfset aux = " Ano: " & #anoinsp# & " Grupo: " & #xml.rootelement.dados[i].RIP_NumGrupo.XmlText# & " e/ou Item : " & #xml.rootelement.dados[i].RIP_NumItem.XmlText# & " Nao cadastrado ou desativado na base do SNCI!">
              <cflocation url="arquivo_dbins_RejeitarXML.cfm?form.motivo=#aux#&form.numrelat=#RIPInspecao#&form.numunid=#RIPUnidade#&form.dtiniinsp=#INPDtInicInsp#&form.nomearquivo=#nomearquivo#&form.excluirsn=N">
         </cfoutput>
	</cfif>

	</cfloop>
<!--- XML fora do padrão quanto ao ponto --->

<!--- Fim Leitura do arquivo --->
</cfif>
		
<cfset origem = cffile.serverdirectory & '\' & cffile.serverfile>
<cfset destino = cffile.serverdirectory & '\dados\' & #Form.numero_inspecao#> 

<cfquery name="rsUnid" datasource="#dsn_inspecao#">
SELECT Und_Descricao FROM Unidades WHERE Und_Codigo = '#RIPUnidade#'
</cfquery>


<!--- <cfparam name="qVerifica.RecordCount" default="0"> --->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="CSS.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {font-size: 10px}
-->
</style>
</head>
<body>


<div align="center">
	<cfinclude template="cabecalho.cfm">
</div>
 <form name="frm1" action="arquivo_dbins_visualizar_action.cfm?flush=true" method="post">
<table align="center">
<!---   <cfif isDefined("Form.arquivo")> --->
  <tr class="titulos">
    <td valign="top" colspan="3"><p align="center"><br>
    </p></td>
  </tr>
  <table width="528" border="1" align="center" class="Tabela">
    <tr>
      <td colspan="2" class="titulosClaro2"><div align="center">AVALIAÇÃO DE CONTROLE INTERNO A SER INCORPORADA ! </div></td>
    </tr>
    <tr>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td width="180" class="titulos">Nro Relatório</td>
      <td width="332" class="exibir"><cfoutput>#RIPInspecao#</cfoutput></td>
    </tr>
    <tr>
      <td class="titulos">Unidade</td>
      <td class="exibir"><cfoutput>#RIPUnidade#</cfoutput> - <cfoutput>#rsUnid.Und_Descricao#</cfoutput></td>
    </tr>
    <tr>
      <td class="titulos">Dt. In&iacute;cio da Avaliação do Controle Interno</td>
	  <cfset auxdtini = INPDtInicInsp>
	  <cfif trim(auxdtini) eq "00:00:00">
	    <cfset auxdtini = DateFormat(now(),"dd/mm/yyyy")>
<!--- 	  <cfelse>
 	    <cfset auxdtini = DateFormat(INPDtInicInsp,"dd/mm/yyyy")> --->
	  </cfif>
      <td class="exibir"><cfoutput>#auxdtini#</cfoutput></td>
    </tr>
    <tr>
      <td class="titulos">Ano</td>
      <td class="exibir"><cfoutput>#RIPAno#</cfoutput></td>
    </tr>
	
    <tr>
      <td class="titulos">Nome do Arquivo </td>
      <td class="exibir"><cfoutput>#Form.numero_inspecao#</cfoutput></td>
    </tr>
    <tr>
      <td colspan="2"><table width="518" border="0">
        <tr>
          <td colspan="2">&nbsp;</td>
        </tr>
        <tr>
		<input type="hidden" name="nome_arquivo" id="nome_arquivo" value="<cfoutput>#nomearquivo#</cfoutput>">
          <td width="248"><div align="center">
            <input type="submit" name="adicionar" class="botao" value="Incorporar">
          </div></td>
          <td width="260">
		  <cfoutput>
            <div align="center">
              <input name="apagar" type="button" class="botao" value="Excluir" onClick="window.open('arquivo_dbins_RejeitarXML.cfm?form.motivo=Desistencia da Incorporacao dos Registros no SNCI&form.numrelat=<cfoutput>#RIPInspecao#</cfoutput>&form.numunid=<cfoutput>#RIPUnidade#</cfoutput>&form.dtiniinsp=<cfoutput>#DateFormat(INPDtInicInsp,"dd/mm/yyyy")#</cfoutput>&form.nomearquivo=<cfoutput>#nomearquivo#</cfoutput>&form.excluirsn=N','_self')">
            </div>
          </cfoutput></td>
        </tr>
      </table></td>
    </tr>
  </table>

