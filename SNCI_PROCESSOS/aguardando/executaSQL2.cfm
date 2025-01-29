<cfprocessingdirective pageencoding = "utf-8">	
<cftransaction>
    


    <cfset dadosPendentes = [
{codigo=4628, status ="P"},
{codigo=4747, status ="P"},
{codigo=4748, status ="P"},
{codigo=4766, status ="P"},
{codigo=4897, status ="P"},
{codigo=4898, status ="P"},
{codigo=4899, status ="P"},
{codigo=4900, status ="P"},
{codigo=4901, status ="P"},
{codigo=4891, status ="P"},
{codigo=4983, status ="P"},
{codigo=4984, status ="P"},
{codigo=4985, status ="P"},
{codigo=4986, status ="P"},
{codigo=4987, status ="P"},
{codigo=4988, status ="P"},
{codigo=4759, status ="P"},
{codigo=4854, status ="P"},
{codigo=4855, status ="P"},
{codigo=4856, status ="P"},
{codigo=4857, status ="P"},
{codigo=4858, status ="P"},
{codigo=4859, status ="P"},
{codigo=3566, status ="P"},
{codigo=3567, status ="P"},
{codigo=3572, status ="P"},
{codigo=3581, status ="P"},
{codigo=5002, status ="P"},
{codigo=5010, status ="P"},
{codigo=3609, status ="P"},
{codigo=4718, status ="P"},
{codigo=4719, status ="P"},
{codigo=4720, status ="P"},
{codigo=4721, status ="P"},
{codigo=4867, status ="P"},
{codigo=4868, status ="P"},
{codigo=4869, status ="P"},
{codigo=4870, status ="P"},
{codigo=4871, status ="P"},
{codigo=4872, status ="P"},
{codigo=4620, status ="P"}

    ]>

    <!--- Contar a quantidade de itens no array --->
    <cfset totalPendentes = ArrayLen(dadosPendentes)>

    <!--- Loop para atualizar o banco de dados --->
    <cfoutput><h3>Registros Pendentes atualizados: #totalPendentes#</h3> </cfoutput>
    <cfloop array="#dadosPendentes#" index="registro">
        <cfquery datasource="#application.dsn_processos#">
            UPDATE pc_avaliacao_melhorias
            SET 
            pc_aval_melhoria_status = <cfqueryparam value="#registro.status#" cfsqltype="cf_sql_varchar">,
            pc_aval_melhoria_naoAceita_justif = null,
            pc_aval_melhoria_sugestao = null
            WHERE pc_aval_melhoria_id = <cfqueryparam value="#registro.codigo#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfoutput>#registro.codigo#, </cfoutput>
    </cfloop>

     <cfset dadosPendentesRefazer = [
        {codigo = 3583, status = "P"},
        {codigo = 3585, status = "P"},
        {codigo = 3586, status = "P"},
        {codigo = 3588, status = "P"},
        {codigo = 3590, status = "P"},
        {codigo = 3592, status = "P"},
        {codigo = 3593, status = "P"},
        {codigo = 3594, status = "P"},
        {codigo = 4714, status = "P"},
        {codigo = 4738, status = "P"},
        {codigo = 4739, status = "P"},
        {codigo = 4740, status = "P"},
        {codigo = 4741, status = "P"},
        {codigo = 4742, status = "P"},
        {codigo = 4743, status = "P"},
        {codigo = 4744, status = "P"},
        {codigo = 4745, status = "P"},
        {codigo = 4746, status = "P"},
        {codigo = 4749, status = "P"},
        {codigo = 4750, status = "P"},
        {codigo = 4751, status = "P"},
        {codigo = 4752, status = "P"},
        {codigo = 4753, status = "P"},
        {codigo = 4754, status = "P"},
        {codigo = 4758, status = "P"},
        {codigo = 4763, status = "P"},
        {codigo = 4764, status = "P"},
        {codigo = 4765, status = "P"},
        {codigo = 4767, status = "P"},
        {codigo = 4768, status = "P"},
        {codigo = 4895, status = "P"},
        {codigo = 4958, status = "P"},
        {codigo = 4959, status = "P"},
        {codigo = 4961, status = "P"},
        {codigo = 4965, status = "P"},
        {codigo = 4966, status = "P"},
        {codigo = 4969, status = "P"},
        {codigo = 4970, status = "P"},
        {codigo = 4971, status = "P"},
        {codigo = 4972, status = "P"},
        {codigo = 4973, status = "P"},
        {codigo = 4974, status = "P"},
        {codigo = 4975, status = "P"},
        {codigo = 4976, status = "P"},
        {codigo = 4977, status = "P"},
        {codigo = 4978, status = "P"},
        {codigo = 4979, status = "P"},
        {codigo = 4991, status = "P"},
        {codigo = 4997, status = "P"},
        {codigo = 4998, status = "P"}
    ]>

    <!--- Contar a quantidade de itens no array --->
    <cfset totalPendentesRefazer = ArrayLen(dadosPendentesRefazer)>

    <!--- Loop para atualizar o banco de dados --->
    <cfoutput><h3>Registros Pendentes Refazer atualizados: #totalPendentesRefazer#</h3></cfoutput>
    <cfloop array="#dadosPendentesRefazer#" index="registro">
        <cfquery datasource="#application.dsn_processos#">
            UPDATE pc_avaliacao_melhorias
            SET 
            pc_aval_melhoria_status = <cfqueryparam value="#registro.status#" cfsqltype="cf_sql_varchar">,
            pc_aval_melhoria_naoAceita_justif = null,
            pc_aval_melhoria_sugestao = null
            WHERE pc_aval_melhoria_id = <cfqueryparam value="#registro.codigo#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfoutput>#registro.codigo#, </cfoutput>
    </cfloop>

    <cfset totalRegistros =  totalPendentes + totalPendentesRefazer>

    <cfoutput><h2>Total de registros atualizados: #totalRegistros#</h2></cfoutput>

</cftransaction>
   



 