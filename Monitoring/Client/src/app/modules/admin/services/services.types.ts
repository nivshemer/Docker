/* eslint-disable @typescript-eslint/naming-convention */

import {Status, Role} from './services.models';
import {Usage} from '../../../shared/models';

export interface IUser {
    Id: string;
    FirstName: string;
    LastName: string;
    UserName: string;
    Role: Role;
    UserGroupId: string;
    PhoneCode: string;
    PhoneNumber: string;
    Email: string;
    Password: string;
}


export interface IService {
    Name: string;
    Status: Status;
    Version: string;
    Usage: Usage;
}
