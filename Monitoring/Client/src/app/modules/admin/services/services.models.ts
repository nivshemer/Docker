/* eslint-disable @typescript-eslint/naming-convention */

import {IService, IUser} from 'app/modules/admin/services/services.types';
import {Usage} from '../../../shared/models';

// -----------------------------------------------------------------------------------------------------
// @ User
// -----------------------------------------------------------------------------------------------------
export class User implements Partial<IUser> {

    Id?: string;
    FirstName?: string;
    LastName?: string;
    UserName?: string;
    Role?: Role;
    UserGroupId?: string;
    PhoneCode?: string;
    PhoneNumber?: string;
    Email?: string;
    Password?: string;

    constructor(user: IUser) {
        this.Id = user.Id;
        this.FirstName = user.FirstName;
        this.LastName = user.LastName;
        this.UserName = user.UserName;
        this.Role = user.Role;
        this.UserGroupId = user.UserGroupId;
        this.PhoneCode = user.PhoneCode;
        this.PhoneNumber = user.PhoneNumber;
        this.Email = user.Email;
        this.Password = user.Password;
    }
}

// -----------------------------------------------------------------------------------------------------
// @ Service
// -----------------------------------------------------------------------------------------------------

export class Service implements Partial<IService> {

    Name?: string;
    Status?: Status;
    Version?: string;
    Usage?: Usage;

    constructor(service: IService) {
        this.Name = service.Name;
        this.Status = service.Status;
        this.Version = service.Version;
        this.Usage = service.Usage;
    }
}

// Types
export type Status = 'running' | 'created' | 'exited' | '';
export type Role = 'admin' | 'supervisor' | 'programmer' | '';
// export type Role = 'Roles.Admin' | 'Roles.Supervisor' | 'Roles.Programmer' | '';

