<cfprocessingdirective pageEncoding ="utf-8">

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
  SELECT Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena, Dir_Descricao, Usu_Matricula,Usu_AtivFacin
  FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
  WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
  order by Dir_Sigla
</cfquery>

<cfquery name="rsAnoPacin" datasource="#dsn_inspecao#">    
    SELECT PTC_Ano 
    FROM Pontuacao 
    GROUP BY PTC_Ano 
    HAVING (PTC_Ano) >= 2018
    order by PTC_Ano desc
</cfquery>   

<cfset auxanoatu = year(now())>
<cfquery name="rsAno" datasource="#dsn_inspecao#">
  SELECT Andt_AnoExerc
  FROM Andamento_Temp
  GROUP BY Andt_AnoExerc
  HAVING Andt_AnoExerc  < '#auxanoatu#'
  ORDER BY Andt_AnoExerc DESC
</cfquery>
<cfset auxse = ''>
<cfset AtivFacin = ucase(trim(qAcesso.Usu_AtivFacin))>
<cfloop list="#AtivFacin#" index="i">
  <cfset auxcol = "#i#">
  <cfset auxse = auxcol>
</cfloop>  
<!--- =========================== --->

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="public/bootstrap/bootstrap.min.css">  
 <link href="css.css" rel="stylesheet" type="text/css">
 <style>
 .table {
  width: 100%;
  border-collapse: collapse;
  }
  td {
    font-size: 12px;
  }

  th {
    font-size: 12px;
  }

</style>
</head>
<br>
<body>

<!--- <cfinclude template="cabecalho.cfm"> --->

<cfset dtpart = year(now()) & '-01-01'>
<!--- area de conteudo   --->
<table width="50%" align="left">
  <tr>
    <td>

    <table class="table table-bordered" width="100%">
	<form action="ficha_facin_gestao_ref.cfm" method="post" target="_blank" name="frmObjeto" onSubmit="return validarform()">

        <tbody>
          <tr>
            <td colspan="5" align="center" class="titulo2"><div class="row"><strong>FICHA DE AVALIAÇÃO (FACIN) - RESULTADOS</strong></div></td>
          </tr>
          <tr>
            <th scope="row">Exercício</th>
            <td align="left" colspan="1">
              <select name="frmano" id="frmano" class="form-select">
                  <cfloop query="rsAnoPacin">                                             
                      <option value="<cfoutput>#rsAnoPacin.PTC_Ano#</cfoutput>"><cfoutput>#rsAnoPacin.PTC_Ano#</cfoutput></option>
                  </cfloop>
              </select>
          </td>
          </tr>
          <tr>
            <th scope="row" colspan="2">Período</th>
          </tr>
          <tr>
            <th scope="row">Início</th>
            <td  colspan="1">
              <input class="form-control" id="dtinic" name="dtinic" type="date" placeholder="DD/MM/AAAA" value="<cfoutput>#dtpart#</cfoutput>">
            </td>
          </tr>
          <tr>
            <th scope="row">Final</th>
            <td colspan="1"><input class="form-control" id="dtfinal" name="dtfinal" type="date" placeholder="DD/MM/AAAA" value="<cfoutput>#dateformat(now(),"yyyy-mm-dd")#</cfoutput>"></td>

          </tr>
          <tr>
            <th scope="row">Superintendência</th>
            <td colspan="1">
            <cfif auxse eq 'D'>	
              <select name="frmse" id="frmse" class="form-select">
                    <option value="" selected>---</option>
                    <option value="<cfoutput>#qAcesso.Usu_DR#</cfoutput>"><cfoutput>#qAcesso.Dir_Sigla#</cfoutput></option>
              </select>	
            <cfelse>
              <cfset auxcord = trim(qAcesso.Usu_Coordena)>
              <cfquery name="rsSE" datasource="#dsn_inspecao#">
                SELECT Dir_Codigo, Dir_Sigla FROM Diretoria where dir_codigo in(#auxcord#)
              </cfquery>
              <select name="frmse" id="frmse" class="form-select">
                <option value="" selected>---</option>
                <cfoutput query="rsSE">
                      <option value="#rsSE.Dir_Codigo#">#Ucase(trim(rsSE.Dir_Sigla))#</option>
                </cfoutput>
              </select>    
            </cfif>	
            </td>

          </tr>
          <tr>
            <th scope="row">Inspetores</th>
            <td colspan="1">
              <select name="frminspetores" id="frminspetores" class="form-select">                                          
                <option value="">---</option>
              </select>
            </td>
          </tr>
          <tr>
            <th scope="row">Avaliações</th>
            <td colspan="1">
              <select name="frmavaliacao" id="frmavaliacao" class="form-select">                                          
                <option value="">---</option>
              </select>
            </td>
          </tr>
        </tbody>
      </table>

<!--- 	  <input name="grupoacesso" type="hidden" value="<cfoutput>#qAcesso.Usu_GrupoAcesso#</cfoutput>">
	  <input name="usucoordena" type="hidden" value="<cfoutput>#qAcesso.Usu_Coordena#</cfoutput>"> --->
	</form>          
      </table>
    </td>
  </tr>
  <tr>
    <td>
      <!---  style="display:none;" --->
	    <div id='table'>
      </div>
    </td>
  </tr>
</table>        


</body>
<script src="public/jquery-3.7.1.min.js"></script>
<script type="text/javascript" src="public/axios.min.js"></script>
<script>
      //buscar o inspetores
      $('#frmse').change(function(e){ 
        let prots = '<option value="" selected>---</option>';
        let dtinic = $('#dtinic').val() 
        dtinic += ' 00:00:00.000'
        let dtfinal = $('#dtfinal').val()
        dtfinal += ' 23:59:59.000'
        if(dtinic == '' || dtfinal == ''){
          alert('Selecionar o período (Início/Final) da FACIN')
          $('#dtinic').focus()
          return false
         }
        if($(this).val() != ''){     
            let ano = $('#frmano').val(); 
            let frmse = $(this).val(); 
            axios.get("CFC/fichafacin.cfc",{
                params: {
                    method: "inspetores",
                    ano: ano,
                    dtinic: dtinic,
                    dtfinal: dtfinal,
                    codse: frmse
                }
            })
            .then(data =>{
            var vlr_ini = data.data.indexOf("COLUMNS");
            var vlr_fin = data.data.length
            vlr_ini = (vlr_ini - 2);
            const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
            const dados = json.DATA;
            dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
            });
            $("#frminspetores").html(prots);
            })  
        }
      })//fim buscar inspetores 
      //buscar o avaliações
      $('#frminspetores').change(function(e){ 
        let prots = '<option value="" selected>---</option>';
        prots += '<option value="t">Todas</option>'
        if($(this).val() != ''){    
            let dtinic = $('#dtinic').val() 
            dtinic += ' 00:00:00.000'
            let dtfinal = $('#dtfinal').val()
            dtfinal += ' 23:59:59.999'
            let ano = $('#frmano').val(); 
            let frmse = $('#frmse').val(); 
            let matr = $(this).val(); 
            //alert(ano + ' ' + frmse + ' ' + matr)
            axios.get("CFC/fichafacin.cfc",{
                params: {
                    method: "avaliacao",
                    ano: ano,
                    codse: frmse,
                    dtinic: dtinic,
                    dtfinal: dtfinal,
                    matr: matr
                }
            })
            .then(data =>{
            var vlr_ini = data.data.indexOf("COLUMNS");
            var vlr_fin = data.data.length
            vlr_ini = (vlr_ini - 2);
            const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
            const dados = json.DATA;
            dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[0]+'-'+ret[1] + '</option>';
            });
            $("#frmavaliacao").html(prots);
            })  
        }
      })//fim buscar avaliações   
      //preencher tabela
      $('#frmavaliacao').change(function(e){ 
        $("#table").hide(500) 
        if($(this).val() != ''){   
            let ano = $('#frmano').val(); 
            let dtinic = $('#dtinic').val() 
            dtinic += ' 00:00:00.000'
            let dtfinal = $('#dtfinal').val()
            dtfinal += ' 23:59:59.999'
            let frmse = $('#frmse').val(); 
            let matrinsp = $('#frminspetores').val(); 
            let aval = $(this).val()
            //alert(ano + ' ' + frmse + ' ' + matr)
            axios.get("CFC/fichafacin.cfc",{
                params: {
                    method: "gestao",
                    ano: ano,
                    dtinic: dtinic,
                    dtfinal: dtfinal,
                    codse: frmse,
                    matrinsp: matrinsp,
                    aval: aval 
                }
            })
            .then(data =>{
              let numocor = 0
              let medmeta1 = 0
              let medmeta2 = 0
              let medmeta3 = 0
              let tab = '<table class="table table-bordered table-hover border-primary">'
              tab += '<thead>'
              tab += '<tr>'
              tab +=  '<th scope="col">Clique no Nº Avaliação</th>'
              tab +=  '<th scope="col">Tipo</th>'
              tab +=  '<th scope="col">Qtd. Avaliação</th>'
              tab +=  '<th scope="col">Qtd. Avaliado</th>'
              tab +=  '<th scope="col">Desconto(Meta1)</th>'
              tab +=  '<th scope="col">Pontos Individual(Meta1)</th>'
              tab +=  '<th scope="col">Resultado(Meta1)</th>'
              tab +=  '<th scope="col">Desconto(Meta2)</th>'
              tab +=  '<th scope="col">Pontos Individual(Meta2)</th>'
              tab +=  '<th scope="col">Resultado(Meta2)</th>'
              tab +=  '<th scope="col">Resultado(Meta3)</th>'
              tab += '</tr>'
              tab += '</thead>'
              tab += '<tbody>'
              var vlr_ini = data.data.indexOf("COLUMNS");
              var vlr_fin = data.data.length
              vlr_ini = (vlr_ini - 2);
              const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
              const dados = json.DATA;
              //FFI_Avaliacao,TUN_Descricao,FAC_Qtd_Geral,FFI_Qtd_Item,FFI_Meta1_Pontuacao_Obtida,FFI_Meta1_Resultado,FFI_Meta2_Pontuacao_Obtida,FFI_Meta2_Resultado,FAC_Perc_Meta3
              dados.map((ret) => {
                numocor++
                medmeta1 = medmeta1 + ret[5]
                medmeta2 = medmeta2 + ret[7]
                medmeta3 = medmeta3 + ret[8]
                descmeta1 = eval(ret[3] - ret[4]).toFixed(2)
                if(descmeta1 < 0){descmeta1=0}
                descmeta2 = eval(ret[3] - ret[6]).toFixed(2)
                if(descmeta2 < 0){descmeta2=0}
                let url = 'href=ficha_facin_gestao_relat.cfm?ninsp='+ret[0]+'&matrinsp='+matrinsp
                //alert(url)
                tab += '<tr>'
                  tab += '<td class="alert alert-primary"><a class="alert-link" '+url+' target="_blank">'+ret[0]+'</a></td>'
                  tab += '<td>'+ret[1]+'</td>'
                  tab += '<td>'+ret[2]+'</td>'
                  tab += '<td>'+ret[3]+'</td>'
                  tab += '<td>'+descmeta1+'</td>'
                  tab += '<td>'+eval(ret[4]).toFixed(2)+'</td>'
                  tab += '<td>'+eval(ret[5]).toFixed(2)+'</td>'
                  tab += '<td>'+descmeta2+'</td>'
                  tab += '<td>'+eval(ret[6]).toFixed(2)+'</td>'
                  tab += '<td>'+eval(ret[7]).toFixed(2)+'</td>'
                  tab += '<td>'+eval(ret[8]).toFixed(2)+'</td>'
                tab += '</tr>'
              });
              tab += '<tr>'
                tab += '<td>Médias</td>'
                tab += '<td></td>'
                tab += '<td></td>'
                tab += '<td></td>'
                tab += '<td></td>'
                tab += '<td></td>'
                tab += '<td>'+eval(medmeta1/numocor).toFixed(2)+'</td>'
                tab += '<td></td>'
                tab += '<td></td>'
                tab += '<td>'+eval(medmeta2/numocor).toFixed(2)+'</td>'
                tab += '<td>'+eval(medmeta3/numocor).toFixed(2)+'</td>'
              tab += '</tr>'
              tab += '</tbody>'
              tab += '</table>'              
              $("#table").html(tab);
              $("#table").show(500)
            })  
        }
      })//fim preencher tabela               
      //Limpar os selects bases   
      $('#frmano').change(function() {
        $("#frmse").val("").change();
        let prots = '<option value="" selected>---</option>';
        $("#frminspetores").html(prots);
        $("#frmavaliacao").html(prots);
        $("#table").hide(500)
      }); 
      $('#frmse').change(function() {
        let prots = '<option value="" selected>---</option>';
        $("#frminspetores").html(prots);
        $("#frmavaliacao").html(prots);
        $("#table").hide(500)
      }); 
      $('#frminspetores').change(function() {
        let prots = '<option value="" selected>---</option>';
        $("#frmavaliacao").html(prots);
        $("#table").hide(500)
      });
      $('#dtinic').change(function() {
        $("#frmse").val("").change();
        let prots = '<option value="" selected>---</option>';
        $("#frminspetores").html(prots);
        $("#frmavaliacao").html(prots);
        $("#table").hide(500)
      });
      $('#dtfinal').change(function() {
        $("#frmse").val("").change();
        let prots = '<option value="" selected>---</option>';
        $("#frminspetores").html(prots);
        $("#frmavaliacao").html(prots);
        $("#table").hide(500)
      }); 
      //final Limpar os selects bases
      $(".external").attr("target","_blank")
</script>
</html>
