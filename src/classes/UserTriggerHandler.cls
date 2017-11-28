public with sharing class UserTriggerHandler {

	private static UserTriggerHandler instance;

	public static Boolean isBeforeExecuting = false;
	public static Boolean isAfterExecuting = false;

	public static UserTriggerHandler getInstance () {

		instance = (instance == null) ? new UserTriggerHandler() : instance;

		return instance;
	}

	private UserTriggerHandler () {}

	public void fire () {

		if (Trigger.isBefore && !isBeforeExecuting) {

			isBeforeExecuting = true;

			if (Trigger.isInsert) {

				beforeInsert();

			} else if (Trigger.isUpdate) {

				beforeUpdate();

			} else if (Trigger.isDelete) {

				beforeDelete();
			}

			isBeforeExecuting = false;

		} else if (Trigger.isAfter && !isAfterExecuting) {

			isAfterExecuting = true;

			if (Trigger.isInsert) {

				afterInsert();

			} else if (Trigger.isUpdate) {

				afterUpdate();

			} else if (Trigger.isDelete) {

				afterDelete();

			} else if (Trigger.isUndelete) {

				afterUndelete();
			}

			isAfterExecuting = false;
		}
	}

	public void beforeInsert () {}

	public void beforeUpdate () {}

	public void beforeDelete () {}

	public void afterInsert () {

		PermissionSetAssignmentManager.managePermissionSetAssignments(
			(Map<Id, User>) Trigger.newMap,
			(Map<Id, User>) Trigger.oldMap
		);
	}

	public void afterUpdate () {

		PermissionSetAssignmentManager.managePermissionSetAssignments(
			(Map<Id, User>) Trigger.newMap,
			(Map<Id, User>) Trigger.oldMap
		);
	}

	public void afterDelete () {}

	public void afterUndelete () {}
}