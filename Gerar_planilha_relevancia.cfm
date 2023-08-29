<cfprocessingdirective pageEncoding ="utf-8"/>  
<cfinclude template="parametros.cfm">
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Sistema Nacional de Controle Interno</title>
        <link href="css.css" rel="stylesheet" type="text/css" />
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
      
        <style type="text/css">
            html {margin:1cm 1cm;}
        </style>

        <script language="javascript">
            function printpr(OLECMDID){
                var OLECMDID = 7;
                /* OLECMDID values:
                * 6 - print
                * 7 - print preview
                * 8 - page setup (for printing)
                * 1 - open window
                * 4 - Save As
                * 10 - properties
                */
                var PROMPT = 1; // 1 PROMPT & 2 DONT PROMPT USER
                var WebBrowser = '<OBJECT ID="WebBrowser1" WIDTH=30 HEIGHT=22 CLASSID="CLSID:8856F961-340A-11D0-A96B-00C04FD705A2"></OBJECT>';
                document.body.insertAdjacentHTML('beforeEnd', WebBrowser);
                WebBrowser1.ExecWB(OLECMDID,PROMPT);
                WebBrowser1.outerHTML = "";
           
            }
        </script>

    
    </head>
<!--- <cfquery name="rsbase" datasource="#dsn_inspecao#">
SELECT Grp_Ano, Grp_Codigo, Grp_Descricao, Itn_TipoUnidade, TUN_Descricao, Itn_NumItem, Itn_Descricao, Itn_PTC_Seq, Itn_Situacao, Itn_Modalidade
FROM (Grupos_Verificacao INNER JOIN Itens_Verificacao ON (Grp_Ano = Itn_Ano) AND (Grp_Codigo = Itn_NumGrupo)) INNER JOIN Tipo_Unidades ON Itn_TipoUnidade = TUN_Codigo
WHERE Grp_Ano = '#url.ano#' and Itn_TipoUnidade = #url.tipo#
order by TUN_Descricao
</cfquery> --->
<cfquery name="rsbase" datasource="#dsn_inspecao#">
SELECT Grp_Ano, Grp_Codigo, Grp_Descricao, Itn_TipoUnidade, TUN_Descricao, Itn_NumItem, Itn_Descricao, Itn_PTC_Seq, Itn_Situacao, Itn_Modalidade
FROM (Grupos_Verificacao INNER JOIN Itens_Verificacao ON (Grp_Ano = Itn_Ano) AND (Grp_Codigo = Itn_NumGrupo)) INNER JOIN Tipo_Unidades ON Itn_TipoUnidade = TUN_Codigo
WHERE Grp_Ano = '#url.ano#' 
order by TUN_Descricao
</cfquery>
<cfquery name="rsComp" datasource="#dsn_inspecao#">
	SELECT PTC_Valor, ptc_descricao
	FROM Pontuacao
	WHERE PTC_Ano='#url.ano#'
</cfquery>
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_Matricula from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<!--- Criação do arquivo CSV --->
<cfset sdata = dateformat(now(),"YYYYMMDDHH")>
<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
<cfset slocal = #diretorio# & 'Fechamento\'>
<cfset sarquivo = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #trim(qUsuario.Usu_Matricula)# & '.csv'>

<!--- Excluir arquivos anteriores ao dia atual --->
<cfdirectory name="qList" filter="*.csv" sort="name desc" directory="#slocal#">
<cfloop query="qList">
	<cfif (left(name,8) lt left(sdata,8)) or (mid(name,12,8) eq trim(qUsuario.Usu_Matricula))>
	  <cffile action="delete" file="#slocal##name#">
	</cfif>
</cfloop>
<cffile action="write" addnewline="no" file="#slocal##sarquivo#" output=''>
<cffile action="Append" file="#slocal##sarquivo#" output='DEPARTAMENTO DE CONTROLE INTERNO'>
<cffile action="Append" file="#slocal##sarquivo#" output='RELEVANCIA - #URL.ANO#'>

    <body id="main_body" style="background:#fff" >

        
        <form id="form1"  name="form1" >
          <div class="exibir" align="left" >
		  <button type="button" onClick="printpr(document.main_body);">Imprimir</button>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <input type="button" value="FECHAR" onclick="window.close()";>
			&nbsp;&nbsp;&nbsp;&nbsp;
			<a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>"><img src="icones/csv.png" width="44" height="35" border="0"></a>			</div>

		  
              <table width="92%" height="395" border="0" cellspacing="4" widtd="100%">
                <thead>
                  <tr >
                    <td height="41" colspan="25" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="center" ><img src="GeraRelatorio/geral/img/logoCorreios.gif" alt="Logo ECT"  width="151" height="39" style="" /></div></td>
                  </tr>
                  <tr >
                    <td colspan="25" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="center" style=""><span class="style2" style="color:#053c5e;font-size:14px;"><strong>DEPARTAMENTO DE CONTROLE INTERNO</strong></span></div></td>
                  </tr>
                  <tr>
                    <td colspan="25" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="center"> <span class="style2"  style="color:#053c5e;font-size:14px"><strong>RELEV&Acirc;NCIA - <cfoutput>#URL.ANO#</cfoutput></strong></span></div></td>
                  </tr>
                  <tr>
                    <td width="15%" colspan="18"  valign="top" bordercolor="999999" bgcolor="" scope="row"></td>
                  </tr>
                </thead>
                <tr>
                  <td colspan="25" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left"></div></td>
                </tr>
                <tr>
                  <td colspan="25" valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</td>
                </tr>
                <tr >
                  <td colspan="25" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left"></div></td>
                </tr>
				<cfset auxcol = ''>
                <tr>
                  <td  valign="top" bordercolor="999999" bgcolor="" scope="row">N&ordm; Grupo</td>
                  <td  valign="top" bordercolor="999999" bgcolor="" scope="row">Descri&ccedil;&atilde;o Grupo </td>
                  <td  valign="top" bordercolor="999999" bgcolor="" scope="row">N&ordm; Item </td>
                  <td  valign="top" bordercolor="999999" bgcolor="" scope="row">Descri&ccedil;&atilde;o Item </td>
				  <cfloop query="rsComp">
					<td  valign="top" bordercolor="999999" bgcolor="" scope="row"><cfoutput>(#rsComp.ptc_valor#)-#rsComp.ptc_descricao#</cfoutput></td>
					<cfset auxcol = auxcol & '(#rsComp.ptc_valor#)-#rsComp.ptc_descricao#' & ';'>
				  </cfloop>				  
                  <td  valign="top" bordercolor="999999" bgcolor="" scope="row">Pontua&ccedil;&atilde;o Total </td>
                  <td  valign="top" bordercolor="999999" bgcolor="" scope="row">Tipo Unidade </td>
                  <td  valign="top" bordercolor="999999" bgcolor="" scope="row">Tipo Avalia&ccedil;&atilde;o </td>
                  <td  valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="center">Status</div></td>
                </tr>
<cffile action="Append" file="#slocal##sarquivo#" output='Grupo;NomeGrupo;Item;NomeItem;#auxcol#TotalPontos;TipoUnid;Tipo Avaliacao;Status'>
				
                <cfoutput query="rsbase">
					  <cfset itnptcseq = trim(Itn_PTC_Seq)>
                      <cfif len(itnptcseq) lte 0>
                        <cfset itnptcseq = 0>
                      </cfif>
                      <cfquery name="rsComp" datasource="#dsn_inspecao#">
                        SELECT PTC_Seq, PTC_Valor
                        FROM Pontuacao
                        WHERE PTC_Ano=#Grp_Ano# and PTC_Seq In (#itnptcseq#)
                      </cfquery>				      
                  <tr>
                    <td valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="justify" style="background:F5F5F5;color:##053c5e;">
                      <div align="center">#Grp_Codigo#</div>
                    </div></td>
                    <td valign="top" bordercolor="999999" bgcolor="F5F5F5" class="Tabela" scope="row">#Grp_Descricao#</td>
                    <td valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="center">#Itn_NumItem#</div></td>
                    <td valign="top" bordercolor="999999" bgcolor="F5F5F5" class="Tabela" scope="row">#Itn_Descricao# </td>
					
<cfset ponto10 = 0>
<cfset ponto11 = 0>
<cfset ponto12 = 0>
<cfset ponto13 = 0>
<cfset ponto14 = 0>
<cfset ponto15 = 0>
<cfset ponto16 = 0>
<cfset ponto17 = 0>
<cfset ponto18 = 0>
<cfset ponto19 = 0>
<cfset pontos = 0>
                   
<cfloop query="rsComp">	
	<cfif rsComp.PTC_Seq is 10>
	  	<cfset ponto10 = rsComp.PTC_Valor>
	<cfelseif rsComp.PTC_Seq is 11>
	  <cfset ponto11 = rsComp.PTC_Valor>
	<cfelseif rsComp.PTC_Seq is 12>
	  <cfset ponto12 = rsComp.PTC_Valor>
	<cfelseif rsComp.PTC_Seq is 13>
	  <cfset ponto13 = rsComp.PTC_Valor>
	<cfelseif rsComp.PTC_Seq is 14>
	  <cfset ponto14 = rsComp.PTC_Valor>
	<cfelseif rsComp.PTC_Seq is 15>
	  <cfset ponto15 = rsComp.PTC_Valor>
	<cfelseif rsComp.PTC_Seq is 16>
	  <cfset ponto16 = rsComp.PTC_Valor>
	<cfelseif rsComp.PTC_Seq is 17>
	  <cfset ponto17 = rsComp.PTC_Valor>
	<cfelseif rsComp.PTC_Seq is 18>
	  <cfset ponto18 = rsComp.PTC_Valor>	  	  	  	  	  	  	  
	<cfelseif rsComp.PTC_Seq is 19>
	  <cfset ponto19 = rsComp.PTC_Valor>
	</cfif>
	<cfset pontos = pontos + rsComp.PTC_Valor> 	
</cfloop>
					<td valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="center">#ponto10#</div></td>			
                    <td valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="center">#ponto11#</div></td>
                    <td valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="center">#ponto12#</div></td>
                    <td valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="center">#ponto13#</div></td>
                    <td valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="center">#ponto14#</div></td>
                    <td valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="center">#ponto15#</div></td>
                    <td valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="center">#ponto16#</div></td>
                    <td valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="center">#ponto17#</div></td>
                    <td valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="center">#ponto18#</div></td>
                    <td valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="center">#ponto19#</div></td>
					
                    <td valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="center">#pontos#</div></td>
					
                    <td valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="center">#TUN_Descricao#</div></td>
                    <td valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row">#rsbase.Itn_Modalidade#</td>
                    <td colspan="10" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="center">#rsbase.Itn_Situacao#</div></td> 
<cffile action="Append" file="#slocal##sarquivo#" output='#Grp_Codigo#;#Grp_Descricao#;#Itn_NumItem#;#Itn_Descricao#;#ponto10#;#ponto11#;#ponto12#;#ponto13#;#ponto14#;#ponto15#;#ponto16#;#ponto17#;#ponto18#;#ponto19#;#pontos#;#TUN_Descricao#;#rsbase.Itn_Modalidade#;#rsbase.Itn_Situacao#'>					
                 </cfoutput>
          </table>
            </div>
    </form>
        <footer>
            <div class="noprint" align="CENTER"><button type="button" onClick="window.print();">Imprimir</button></div>
        </footer>
    </body>
    

    </html>
