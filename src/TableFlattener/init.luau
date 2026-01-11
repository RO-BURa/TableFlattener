local TableFlattener = {}

function TableFlattener.Encode(tbl)
	local tables = {}

	local id = tostring(tbl)

	local function discover(t)
		local tableId = tostring(t)

		local result = { Id = tableId }

		local infoTable = tables[tableId]

		local infoTable_LEN = 0

		if not infoTable then
			infoTable = {}

			tables[tableId] = infoTable

			for index, value in t do
				if typeof(index) == "table" then
					index = discover(index)
				end

				if typeof(value) == "table" then
					value = discover(value)
				end

				local indexAndValue = {
					Index = index,
					Value = value,
				}

				infoTable[tostring(infoTable_LEN + 1)] = indexAndValue
				infoTable_LEN += 1
			end
		end

		return result
	end

	discover(tbl)

	return {
		Tables = tables,
		Id = id,
	}
end

function TableFlattener.Decode(flattedTable)
	local unflattedTableById = {}

	local function discover(wrappedId: { Id: string })
		if unflattedTableById[wrappedId.Id] then
			return unflattedTableById[wrappedId.Id]
		end

		local flattedTable = flattedTable.Tables[wrappedId.Id]

		local unflattedTable = {}

		unflattedTableById[wrappedId.Id] = unflattedTable

		if not flattedTable then
			return unflattedTable
		end

		for _, indexAndValue in flattedTable do
			indexAndValue = table.clone(indexAndValue)

			if typeof(indexAndValue.Index) == "table" then
				indexAndValue.Index = discover(indexAndValue.Index)
			end
			if typeof(indexAndValue.Value) == "table" then
				indexAndValue.Value = discover(indexAndValue.Value)
			end

			unflattedTable[indexAndValue.Index] = indexAndValue.Value
		end

		return unflattedTable
	end

	discover({ Id = flattedTable.Id })

	return unflattedTableById[flattedTable.Id]
end

return TableFlattener
