public with sharing class PermissionSetAssignmentManager {

	private static Map<String, Id> permissionSetNameMap;
	private static Map<Id, PermissionSet> permissionSetMap;
	private static Map<Id, Map<Id, Id>> permissionSetToUserToAssignmentMap;

	static {

		permissionSetNameMap = new Map<String, Id>();
		permissionSetMap = new Map<Id, PermissionSet>();
		permissionSetToUserToAssignmentMap = new Map<Id, Map<Id, Id>>();

		for (PermissionSet ps : [SELECT Id, Name, (SELECT AssigneeId, PermissionSetId FROM Assignments)
									FROM PermissionSet
									WHERE IsCustom = TRUE
									AND IsOwnedByProfile = FALSE]) {

			permissionSetNameMap.put(ps.Name, ps.Id);

			permissionSetMap.put(ps.Id, ps);

			Map<Id, Id> assignmentMap = new Map<Id, Id>();

			for (PermissionSetAssignment psa : ps.Assignments)
				assignmentMap.put(psa.AssigneeId, psa.Id);

			permissionSetToUserToAssignmentMap.put(ps.Id, assignmentMap);
		}
	}

	public static void managePermissionSetAssignments (Map<Id, User> newMap, Map<Id, User> oldMap) {

		Map<Id, List<String>> permissionSetsToUpsertPerUserMap = new Map<Id, List<String>>();
		Map<Id, List<String>> permissionSetsToDeletePerUserMap = new Map<Id, List<String>>();

		for (User u : newMap.values()) {

			List<String> addedPermisssionSets = new List<String>();
			List<String> deletedPermissionSets = new List<String>();

			if (oldMap == null) {

				if (u.PermissionSets__c != null)
					addedPermisssionSets.addAll(u.PermissionSets__c.split(';'));

			} else {

				if (oldMap.containsKey(u.Id) && oldMap.get(u.Id) != null) {

					User oldU = oldMap.get(u.Id);

					if (u.PermissionSets__c != null) {

						for (String psName : u.PermissionSets__c.split(';')) {

							if ((oldU.PermissionSets__c == null || !oldU.PermissionSets__c.contains(psName)) && permissionSetNameMap.containsKey(psName)) 
								addedPermisssionSets.add(psName);
						}
					}

					if (oldU.PermissionSets__c != null) {

						for (String psName : oldU.PermissionSets__c.split(';')) {

							if ((u.PermissionSets__c == null || !u.PermissionSets__c.contains(psName)) && permissionSetNameMap.containsKey(psName))
								deletedPermissionSets.add(psName);
						}
					}

					permissionSetsToUpsertPerUserMap.put(u.Id, addedPermisssionSets);
					permissionSetsToDeletePerUserMap.put(u.Id, deletedPermissionSets);
				}
			}
		}

		Map<Id, PermissionSetAssignment> assignmentsToUpsert = createAssignmentList(permissionSetsToUpsertPerUserMap);
		upsert assignmentsToUpsert.values();

		Map<Id, PermissionSetAssignment> assigmentsToDelete = createAssignmentList(permissionSetsToDeletePerUserMap);
		assigmentsToDelete.remove(null);
		delete assigmentsToDelete.values();
	}

	private static Map<Id, PermissionSetAssignment> createAssignmentList (Map<Id, List<String>> userPSAsToGenerate) {

		Map<Id, PermissionSetAssignment> assignmentsToReturn = new Map<Id, PermissionSetAssignment>();

		for (Id userId : userPSAsToGenerate.keySet()) {

			for (String psName : userPSAsToGenerate.get(userId)) {

				Id permissionSetId = (permissionSetNameMap.containsKey(psName))
					? permissionSetNameMap.get(psName)
					: null;

				Map<Id, Id> userAssignments = (permissionSetId != null && permissionSetToUserToAssignmentMap.containsKey(permissionSetId))
					? permissionSetToUserToAssignmentMap.get(permissionSetId)
					: null;

				Id existingAssignmentId = (userAssignments != null && userAssignments.containsKey(userId))
					? userAssignments.get(userId)
					: null; 

				assignmentsToReturn.put(
					existingAssignmentId,
					new PermissionSetAssignment(
						Id = existingAssignmentId,
						AssigneeId = userId,
						PermissionSetId = permissionSetNameMap.get(psName)
					)
				);
			}
		}

		return assignmentsToReturn;
	}
}