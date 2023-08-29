<cffile action="read" file="#GetDirectoryFromPath(gettemplatepath())#Dados\inspecao.xml" variable="XmlDoc">
<!---Dessa forma ja estamos lendo nosso arquivo .xml--->
<cfset xml = XmlParse(XmlDoc)>
<!---Converte o string pra XML---> 

<!---Nossa array apresenta o tipo de arquivo + o nome da chave + o nome da chave primaria do xml---> 

<cfloop from="1" to="#ArrayLen(xml.rootelement.dados)#" index="i"> 
<!--- As linhas abaixo servem para substituir o uso de aspas simples e duplas, a fim de evitar erros em instruções SQL --->
<cfset strcomentario = xml.rootelement.dados[i].RIP_Comentario.XmlText>
    <cfset strcomentario = Replace(strcomentario,'"','','All')>
	<cfset strcomentario = Replace(strcomentario,"'","","All")>
	<cfset strcomentario = Replace(strcomentario,'&','','All')>
	<cfset strcomentario = Replace(strcomentario,'*','','All')>
	<cfset strcomentario = Replace(strcomentario,'%','','All')> 
	<!--- ================================= --->
<cfset strrecomendacao = xml.rootelement.dados[i].RIP_Recomendacoes.XmlText>
	<cfset strrecomendacao = Replace(strrecomendacao,'"','','All')>
	<cfset strrecomendacao = Replace(strrecomendacao,"'","","All")>
	<cfset strrecomendacao = Replace(strrecomendacao,'&','','All')>
	<cfset strrecomendacao = Replace(strrecomendacao,'*','','All')>
	<cfset strrecomendacao = Replace(strrecomendacao,'%','','All')>

<cfquery datasource="DBINS_TESTE">
INSERT INTO Resultado_Inspecao VALUES (
<!---Da mesma forma que no loop utilizamos as chaves do arquivo e os atributos do XML--->
'#xml.rootelement.dados[i].RIP_Unidade.XmlText#',
'#xml.rootelement.dados[i].RIP_NumInspecao.XmlText#',
#xml.rootelement.dados[i].RIP_NumGrupo.XmlText#,
#xml.rootelement.dados[i].RIP_NumItem.XmlText#,
'#xml.rootelement.dados[i].RIP_CodDiretoria.XmlText#',
'#xml.rootelement.dados[i].RIP_CodReop.XmlText#',
#xml.rootelement.dados[i].RIP_Ano.XmlText#,
'#xml.rootelement.dados[i].RIP_Resposta.XmlText#',
'#strcomentario#',
#DateFormat(xml.rootelement.dados[i].RIP_DtUltAtu.XmlText,"DD/MM/YYYY")#,
'#xml.rootelement.dados[i].RIP_UserName.XmlText#',
'#strrecomendacao#',
<cfif xml.rootelement.dados[i].RIP_Situacao.XmlText is ''> 
'-',
<cfelse>
'#xml.rootelement.dados[i].RIP_Situacao.XmlText#',
</cfif>
<cfif xml.rootelement.dados[i].RIP_Observacao.XmlText is ''>
'-'
<cfelse>
'#xml.rootelement.dados[i].RIP_Observacao.XmlText#'
</cfif>
)
</cfquery>
</cfloop>

<!--Mover Arquivo .xml para pasta Backup-->
<style type="text/css">
<!--
.style1 {
	color: #FF0000;
	font-weight: bold;
}
-->
</style>

<br><br><br><br><br><br>
<div align="center" class="style1">Operação realizada com sucesso</div>
