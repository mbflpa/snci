<cfinclude template="../../../parametros.cfm">
<!---  --->
<cfoutput>
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_Matricula from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<!--- Cria��o do arquivo CSV --->
<cfset sdata = dateformat(now(),"YYYYMMDDHH")>

<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
<cfset diretorio = left(diretorio,Find('SNCI','#diretorio#')-1) & 'SNCI\'> 
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
<cffile action="Append" file="#slocal##sarquivo#" output='PLANO DE TESTE COM PONTUA��O'>
</cfoutput>
<cfquery name="rsChecklistFiltrado" datasource="#dsn_inspecao#">
    SELECT TUI_Modalidade,TUI_TipoUnid,TUI_Ativo, TUI_Ano, TUI_GRUPOITEM, TUI_ITEMVERIF, TUN_Descricao, Grp_Descricao
            , Itn_Descricao, Itn_Orientacao, Itn_ValorDeclarado, Itn_Amostra, Itn_Norma, Itn_Pontuacao, Itn_Classificacao, Itn_PTC_Seq, Itn_Ano, Itn_PreRelato
    FROM TipoUnidade_ItemVerificacao 
    INNER JOIN Grupos_Verificacao ON Grp_Codigo = TUI_GrupoItem AND Grp_Ano = TUI_Ano 
    INNER JOIN Itens_Verificacao ON Itn_NumItem = TUI_ItemVerif AND Itn_NumGrupo = TUI_GrupoItem AND Grp_Ano = Itn_Ano AND TUI_TipoUnid = Itn_TipoUnidade and (TUI_Modalidade = Itn_Modalidade)
    INNER JOIN Tipo_Unidades ON TUN_Codigo = TUI_TipoUnid
    WHERE TUI_Ano = '#url.ano#' <!--- and Tui_Ativo = 1 --->
    <cfif '#url.tipo#' neq ''>
            AND TUI_TipoUnid = '#url.tipo#'
    </cfif>
    <cfif '#url.mod#' neq '2' and  '#url.mod#' neq ''>
        AND TUI_Modalidade = '#url.mod#'
    </cfif>
    <cfif '#url.grupo#' neq ''>
        AND TUI_GrupoItem = '#url.grupo#'
    </cfif>
    <cfif '#url.sit#' neq ''>
        AND TUI_Ativo = #url.sit#
    </cfif>
    <cfif '#url.valDec#' neq ''>
        AND Itn_ValorDeclarado = '#url.valDec#'
    </cfif>
    ORDER BY TUI_GRUPOITEM, TUI_ITEMVERIF, TUN_Descricao  
</cfquery>


    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Sistema Nacional de Controle Interno</title>
        <link href="../../../css.css" rel="stylesheet" type="text/css" />
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
                var WebBrowser = '<OBJECT ID="WebBrowser1" WIDTH=0 HEIGHT=0 CLASSID="CLSID:8856F961-340A-11D0-A96B-00C04FD705A2"></OBJECT>';
                document.body.insertAdjacentHTML('beforeEnd', WebBrowser);
                WebBrowser1.ExecWB(OLECMDID,PROMPT);
                WebBrowser1.outerHTML = "";
           
            }
        </script>

    
    </head>

    <body id="main_body" style="background:#fff" >

        
        <form id="formPlanoTeste"  name="formPlanoTeste" >
         

            <table widtd="100%" border="0" cellspacing="4">
               <thead>
			     <tr>
	<td></td>
    <td> <div class="noprint" align="left" >
      <div align="center">
        <button type="button" onClick="printpr(document.main_body);">Imprimir</button>
      </div>
    </div></td>
    <td></td>
    <td><div align="center"><a href="<cfoutput>#url_csvxls##sarquivo#</cfoutput>"><img src="../../../icones/csv.png" width="45" height="38" border="0"></a></div></td>
    <td colspan="9">&nbsp;</td>
    </tr>
                    <tr >  
                        <td colspan="6" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="center" ><img src="../../geral/img/logoCorreios.gif" alt="Logo ECT"  width="150px" style=""></img></div></td>
                    </tr>
                    <tr >  
                        <td colspan="5" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="center" style=""><span class="style2" style="color:#053c5e;font-size:14px;"><strong>DEPARTAMENTO DE CONTROLE INTERNO</strong></span></div></td>
                        <td valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</td>
                    </tr>
                    <tr>
                        <td colspan="6" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="center"> <span class="style2"  style="color:#053c5e;font-size:14px"><strong>PLANO DE TESTE</strong></span> COM PONTUA&Ccedil;&Atilde;O </div> </td>
                    </tr>
<!---                     <tr>
                        <td  valign="top" bordercolor="999999" bgcolor="" scope="row"></td>
                    </tr> --->
              </thead>

                <tr>
                    <td colspan="6" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left"> <span class="style2"  style="color:#053c5e;">Tipo de Unidade: <CFOUTPUT><strong>#rsChecklistFiltrado.TUN_Descricao#</strong></CFOUTPUT></span> </div> </td>
                </tr>
<cffile action="Append" file="#slocal##sarquivo#" output='Tipo de Unidade:;#rsChecklistFiltrado.TUN_Descricao#'>	
 				<cfif #url.mod# eq 0> 
					<cfset modal = 'PRESENCIAL'>
				<cfelseif #url.mod# eq 1>
					<cfset modal = 'A DIST�NCIA'>
				<cfelse>
				    <cfset modal = 'PRESENCIAL e A DIST�NCIA'>
		        </cfif>		
              <tr>
                <td colspan="6" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left"> <span class="style2"  style="color:#053c5e;">Modalidade: <strong><cfoutput>#modal#</cfoutput></strong></span></div> </td>
              </tr> 
<cffile action="Append" file="#slocal##sarquivo#" output='Modalidade:;#modal#'>				
                <tr>
                    <td colspan="6" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left"> <span class="style2"  style="color:#053c5e">Ano: <CFOUTPUT><strong>#rsChecklistFiltrado.TUI_Ano#</strong></CFOUTPUT></span> </div> </td>
                </tr>
                <tr>
                        <td  valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</td>
                </tr>
<cffile action="Append" file="#slocal##sarquivo#" output='Ano:;#rsChecklistFiltrado.TUI_Ano#'>	
                <cfoutput query="rsChecklistFiltrado" group="TUI_GRUPOITEM">
<!--- <cffile action="Append" file="#slocal##sarquivo#" output=''>   --->                  
                    <tr> 
                        <td colspan="8" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="justify" style="background:F5F5F5;color:##053c5e;"><strong>GRUPO: #TUI_GRUPOITEM# #Grp_Descricao#</strong></div></td>
                    </tr>
<cffile action="Append" file="#slocal##sarquivo#" output='Grupo:;#TUI_GRUPOITEM#;#Grp_Descricao#'>	
                    <cfoutput>                    
                        <tr>
                                <td colspan="8" valign="top" bordercolor="999999" bgcolor="" scope="row"><div style="text-align: justify;"><strong>Item: #TUI_GRUPOITEM#.#TUI_ITEMVERIF# - </strong>#Itn_Descricao#</div></td>
                        </tr>
<cffile action="Append" file="#slocal##sarquivo#" output='Item:;#TUI_GRUPOITEM#.#TUI_ITEMVERIF#;#Itn_Descricao#'>						
<tr>
    <td><strong>Relev�ncia:</strong></td>
    <td><div align="right"><strong>Pontua��o:</strong></div></td>
    <td width="12%"><div align="center"><strong>#Itn_Pontuacao#</strong></div></td>
    <td width="9%"><div align="right"><strong>Classifica��o:</strong></div></td>
    <td width="62%"><strong>&nbsp;#Itn_Classificacao#</strong></td>
    </tr>
<cffile action="Append" file="#slocal##sarquivo#" output='Relev�ncia:;Pontua��o:  #Itn_Pontuacao#;Classifica��o:  #Itn_Classificacao#'>		
	<tr>
    <td colspan="8"><div align="left"><strong>Composi��o da Pontua��o</strong></div></td>
    </tr>
<cffile action="Append" file="#slocal##sarquivo#" output='Composi��o da Pontua��o'>	
	
	<cfset itnptcseq = trim(rsChecklistFiltrado.Itn_PTC_Seq)>
	<cfif len(itnptcseq) lte 0>
	  <cfset itnptcseq = 0>
	</cfif>
	<cfquery name="rsComp" datasource="#dsn_inspecao#">
		SELECT PTC_Seq, PTC_Valor, PTC_Descricao
		FROM Pontuacao
		WHERE PTC_Ano=#Itn_Ano# and PTC_Seq In (#itnptcseq#)
	</cfquery>
<tr>
    <td><div align="center"><strong>ID</strong></div></td>
    <td><div align="center"><strong>Peso</strong></div></td>
    <td colspan="3" ><strong>Descri&ccedil;&atilde;o</strong></td>
  </tr>
<cffile action="Append" file="#slocal##sarquivo#" output='ID;Peso;Descri��o'>
  <cfloop query="rsComp">
  <tr>
    <td><div align="center">#rsComp.PTC_Seq#</div></td>
    <td><div align="center">#rsComp.PTC_Valor#</div></td>
    <td colspan="3" >#rsComp.PTC_Descricao#</td>
  </tr>	
  <cffile action="Append" file="#slocal##sarquivo#" output='#rsComp.PTC_Seq#;#rsComp.PTC_Valor#;#rsComp.PTC_Descricao#'>
  </cfloop> 
 <cffile action="Append" file="#slocal##sarquivo#" output=''>
<!---   <cfset ItnPreRelato = Replace(Itn_PreRelato,"
                      ","<BR>" ,"All")>
                  <cfset ItnPreRelato = Replace(ItnPreRelato,"-----------------------------------------------------------------------------------------------------------------------","<BR>-----------------------------------------------------------------------------------------------------------------------<BR>" ,"All")>
                  <tr>
                    <td colspan="5"><div align="left"><strong>Pr�-Relato</strong></div></td>
                  </tr>
      <tr>
      <td colspan="5">#ItnPreRelato#</td>
    </tr> --->
  
                        <tr>
                            <td  valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</td>
                        </tr>
                    </cfoutput>
                    <tr>
                        <td  colspan="10" valign="top" bordercolor="999999" bgcolor=""  scope="row">&nbsp;</td>
                    </tr>
                </cfoutput> 
          </table>
        
        </form>
        <footer>
            <div class="noprint" align="CENTER"><button type="button" onClick="window.print();">Imprimir</button></div>
        </footer>
    </body>
    

    </html>
